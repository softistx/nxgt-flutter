import 'package:flutter/material.dart';
import 'package:nxgt_material/src/actions/load_more_button.dart';
import 'package:nxgt_material/src/collections/paged_list_state.dart';
import 'package:nxgt_material/src/feedback/async_view.dart';
import 'package:nxgt_material/src/feedback/error_state.dart';
import 'package:nxgt_material/src/feedback/loading_state.dart';

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
  /// button there. A failure of [onLoadMore] does not call it: the list
  /// retries that load itself.
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
  State<PagedList<T>> createState() => PagedListState<T>();
}
