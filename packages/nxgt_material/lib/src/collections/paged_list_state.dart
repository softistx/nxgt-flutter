import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nxgt_material/src/collections/paged_list.dart';
import 'package:nxgt_material/src/collections/paged_list_announcement.dart';
import 'package:nxgt_material/src/collections/paged_list_footer.dart';
import 'package:nxgt_material/src/feedback/async_view.dart';

/// The state of a [PagedList]; not exported.
class PagedListState<T> extends State<PagedList<T>> {
  ScrollController? _owned;
  bool _running = false;
  Object? _loadError;
  // Item count when the page being waited for was requested; null when no
  // landing is expected.
  int? _loadBase;
  // The item count a load was last started at, so a load that adds nothing
  // is not repeated in a loop.
  int? _triggeredAt;
  int _added = 0;
  int _serial = 0;

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
  void didUpdateWidget(PagedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _owned)!.removeListener(_maybeLoadOnScroll);
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
      _added = widget.items.length - base;
      _serial++;
    }
    if (widget.items.length < (_triggeredAt ?? 0)) _triggeredAt = null;
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeLoadOnScroll);
    _owned?.dispose();
    super.dispose();
  }

  void _report(Object error, StackTrace stack, String context) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'nxgt_material',
        context: ErrorDescription(context),
      ),
    );
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
      _report(error, stack, 'while loading more items of a PagedList');
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
    try {
      await widget.onRefresh!();
    } on Object catch (error, stack) {
      _report(error, stack, 'while refreshing a PagedList');
      return;
    }
    if (!mounted) return;
    setState(() {
      _triggeredAt = null;
      _loadError = null;
    });
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

  Widget _list(BuildContext context, List<T> items) {
    final footer = buildPagedListFooter(
      failed: _failed,
      onRetry: widget.error != null ? widget.onRetry : _loadMore,
      loading: widget.loading || (_running && !_isButton),
      showButton: widget.hasMore && _isButton,
      onLoadMore: _loadMore,
    );
    final count = items.length + (footer == null ? 0 : 1);
    Widget item(BuildContext context, int index) => index < items.length
        ? widget.itemBuilder(context, items[index], index)
        : footer!;
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
        PagedListAnnouncement(count: _added, serial: _serial),
      ],
    );
  }
}
