import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nxgt_material/src/actions/load_more_button.dart';
import 'package:nxgt_material/src/feedback/async_view.dart';
import 'package:nxgt_material/src/feedback/error_state.dart';
import 'package:nxgt_material/src/feedback/live_region.dart';
import 'package:nxgt_material/src/feedback/loading_state.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// How a [PagedList] asks for its next page.
enum LoadMoreMode {
  /// A "Show more" [LoadMoreButton] at the end of the list.
  button,

  /// Automatically, when the scroll position is within about one viewport of
  /// the end.
  onScroll,
}

/// A scrolling list that loads its items page by page.
///
/// Prefer it to a hand-written `ListView` with a "load more" flag: it shows
/// the first load, the failure and the empty state through [AsyncView]'s
/// states, loads the next page with a [LoadMoreButton] or on scroll, refreshes
/// by pulling down, and announces "N more loaded" to screen readers when a
/// page lands. It is a vertical `ListView`: give it a bounded height (a
/// `Scaffold` body, an `Expanded`); `shrinkWrap` and a sliver variant are not
/// offered.
///
/// The caller owns the data: pass the [items] loaded so far, and update them
/// when [onLoadMore] or [onRefresh] has fetched more.
///
/// **First load.** While [items] is empty, [loading] shows a [LoadingState],
/// [error] an [ErrorState] with [onRetry], and neither an [empty] state.
/// Once there are items, [loading] shows a [LoadingState] at the end (a page
/// is on its way) and [error] an inline [ErrorState] at the end, with
/// [onRetry]; no page is requested automatically while [error] is set.
///
/// **Next page.** [onLoadMore] is never called while a previous call is
/// running (or [loading] is true). If it throws, the error is reported with
/// [FlutterError.reportError], an inline [ErrorState] replaces the button, and
/// [LoadMoreMode.onScroll] stops loading until the retry succeeds. After a
/// page lands, "N more loaded" is announced, N being the growth of [items].
class PagedList<T> extends StatefulWidget {
  /// Creates a PagedList.
  const new({
    required this.items,
    required this.itemBuilder,
    this.hasMore = false,
    this.onLoadMore,
    this.onRefresh,
    this.loading = false,
    this.error,
    this.onRetry,
    this.empty,
    this.errorBuilder,
    this.loadMoreMode = LoadMoreMode.button,
    this.separatorBuilder,
    this.padding,
    this.controller,
    super.key,
  }) : assert(
         !hasMore || onLoadMore != null,
         'PagedList.hasMore is true but onLoadMore is null.',
       );

  /// The items loaded so far.
  final List<T> items;

  /// Builds the row of an item from its index in [items].
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Whether another page exists. When false no button is shown and nothing
  /// is requested.
  final bool hasMore;

  /// Loads the next page; the caller adds it to [items]. Never called while
  /// a previous call runs.
  final Future<void> Function()? onLoadMore;

  /// Refreshes the list when the user pulls down; `null` disables the pull.
  /// The pull is available once there are items.
  final Future<void> Function()? onRefresh;

  /// Whether the first page (with no [items] yet), or a page requested by the
  /// caller, is loading.
  final bool loading;

  /// The failure of the first page (with no [items] yet), or of a page
  /// requested by the caller (inline, at the end).
  final Object? error;

  /// Runs the retry of the failure shown for [error]; `null` shows no retry
  /// button there.
  final Future<void> Function()? onRetry;

  /// Shown instead of the default `EmptyState` when [items] is empty and
  /// nothing loads or failed.
  final Widget? empty;

  /// Builds the first-load failure; defaults to an [ErrorState] with
  /// [onRetry]. The inline failure at the end is always an [ErrorState].
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Whether the next page is asked for with a button or on scroll.
  final LoadMoreMode loadMoreMode;

  /// Builds the separator between two items. It is not drawn after the last
  /// item.
  final IndexedWidgetBuilder? separatorBuilder;

  /// The padding around the items.
  final EdgeInsetsGeometry? padding;

  /// Controls the scroll position. The list never disposes it; when none is
  /// given the list creates and disposes its own.
  final ScrollController? controller;

  @override
  State<PagedList<T>> createState() => _PagedListState<T>();
}

class _PagedListState<T> extends State<PagedList<T>> {
  ScrollController? _owned;
  Timer? _announceTimer;
  bool _running = false;
  Object? _loadError;
  // Item count when the page being waited for was requested; null when no
  // landing is expected.
  int? _loadBase;
  // The item count a load was last started at, so a load that adds nothing
  // is not repeated in a loop.
  int? _triggeredAt;
  int _announced = 0;

  ScrollController get _controller => widget.controller ?? _owned!;
  bool get _isButton => widget.loadMoreMode == LoadMoreMode.button;
  bool get _busy => _running || widget.loading;
  bool get _failed => _loadError != null || widget.error != null;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _owned = ScrollController();
    _controller.addListener(_maybeLoadOnScroll);
  }

  @override
  void didUpdateWidget(PagedList<T> old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _owned)!.removeListener(_maybeLoadOnScroll);
      if (widget.controller == null) {
        _owned = ScrollController();
      } else {
        _owned?.dispose();
        _owned = null;
      }
      _controller.addListener(_maybeLoadOnScroll);
    }
    final base = _loadBase;
    if (base != null && widget.items.length > base) {
      _loadBase = null;
      _announce(widget.items.length - base);
    }
    if (widget.items.length < (_triggeredAt ?? 0)) _triggeredAt = null;
  }

  @override
  void dispose() {
    _announceTimer?.cancel();
    _controller.removeListener(_maybeLoadOnScroll);
    _owned?.dispose();
    super.dispose();
  }

  void _announce(int count) {
    _announceTimer?.cancel();
    _announced = count;
    // Cleared after a moment so the next page, even of the same size, is
    // announced again.
    _announceTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _announced = 0);
    });
  }

  Future<void> _loadMore() async {
    final load = widget.onLoadMore;
    if (load == null || _busy) return;
    _running = true;
    _loadBase = widget.items.length;
    _triggeredAt = widget.items.length;
    if (!_isButton) setState(() {});
    try {
      await load();
      _loadError = null;
    } on Object catch (error, stack) {
      _loadBase = null;
      _loadError = error;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'nxgt_material',
          context: ErrorDescription('while loading more items of a PagedList'),
        ),
      );
    } finally {
      _running = false;
      if (mounted) {
        setState(() {});
        // A landing is only expected in the frame that follows the load.
        WidgetsBinding.instance
          ..addPostFrameCallback((_) => _loadBase = null)
          ..ensureVisualUpdate();
      }
    }
  }

  Future<void> _refresh() async {
    final refresh = widget.onRefresh;
    if (refresh == null) return;
    await refresh();
    _triggeredAt = null;
    _loadError = null;
  }

  void _maybeLoadOnScroll() {
    if (!mounted ||
        _isButton ||
        !widget.hasMore ||
        widget.onLoadMore == null ||
        _busy ||
        _failed ||
        _triggeredAt == widget.items.length ||
        !_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    if (!position.hasContentDimensions) return;
    if (position.extentAfter <= position.viewportDimension) {
      unawaited(_loadMore());
    }
  }

  Widget? _footer() {
    if (_failed) {
      return ErrorState(
        onRetry: widget.error != null ? widget.onRetry : _loadMore,
      );
    }
    if (widget.loading || (_running && !_isButton)) return const LoadingState();
    if (widget.hasMore && _isButton) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: LoadMoreButton(onPressed: _loadMore)),
      );
    }
    return null;
  }

  Widget _list(BuildContext context, List<T> items) {
    final footer = _footer();
    final count = items.length + (footer == null ? 0 : 1);
    Widget item(BuildContext context, int index) => index < items.length
        ? widget.itemBuilder(context, items[index], index)
        // Desktop density would shrink the footer's buttons below 48 dp.
        : Theme(
            data: Theme.of(context).copyWith(
              visualDensity: VisualDensity.standard,
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
            child: footer!,
          );
    final physics = widget.onRefresh == null
        ? null
        : const AlwaysScrollableScrollPhysics();
    final separator = widget.separatorBuilder;
    final list = separator == null
        ? ListView.builder(
            controller: _controller,
            physics: physics,
            padding: widget.padding,
            itemCount: count,
            itemBuilder: item,
          )
        : ListView.separated(
            controller: _controller,
            physics: physics,
            padding: widget.padding,
            itemCount: count,
            itemBuilder: item,
            separatorBuilder: (context, index) => index >= items.length - 1
                ? const SizedBox.shrink()
                : separator(context, index),
          );
    // Checked after each layout: a first page shorter than the viewport must
    // load the next one without any scrolling.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadOnScroll());
    return widget.onRefresh == null
        ? list
        : RefreshIndicator(onRefresh: _refresh, child: list);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final error = widget.error;
    final snapshot = items.isNotEmpty
        ? AsyncSnapshot<List<T>>.withData(ConnectionState.done, items)
        : widget.loading
        ? AsyncSnapshot<List<T>>.waiting()
        : error != null
        ? AsyncSnapshot<List<T>>.withError(ConnectionState.done, error)
        : AsyncSnapshot<List<T>>.withData(ConnectionState.done, items);
    final errorBuilder = widget.errorBuilder;
    final message = _announced > 0
        ? context.materialL10n.collectionsLoadedMore(_announced)
        : null;
    return Stack(
      fit: StackFit.expand,
      children: [
        AsyncView<List<T>>(
          snapshot: snapshot,
          isEmpty: (items) => items.isEmpty,
          empty: widget.empty,
          onRetry: widget.onRetry,
          errorBuilder: errorBuilder == null
              ? null
              : (context, error, _) => errorBuilder(context, error),
          builder: _list,
        ),
        if (message != null)
          Positioned(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
            // The role and the live region sit on two nodes: Flutter refuses
            // both on one.
            child: Semantics(
              container: true,
              role: SemanticsRole.status,
              child: Semantics(
                container: true,
                liveRegion: liveRegionUnderRole,
                label: message,
                child: const SizedBox.expand(),
              ),
            ),
          ),
      ],
    );
  }
}
