# PagedList

Library: `package:nxgt_material/collections.dart`

A scrolling list that loads its items page by page: the first load, the
failure and the empty state, a "Show more" button or load-on-scroll, pull to
refresh, and an "N more loaded" announcement for screen readers.

## When to use it

For a list the server returns in pages (cursor or offset). You keep the data
(a bloc, a provider, `setState`); `PagedList` shows it and asks for more. For
a list that is loaded whole, use `AsyncView` with a `ListView`.

It is a vertical `ListView`: give it a bounded height (a `Scaffold` body, an
`Expanded`). `shrinkWrap` and a sliver variant are not offered. For a sliver
layout, build the list yourself with `LoadMoreButton`.

- **First load.** While `items` is empty: `loading` shows a `LoadingState`,
  `error` an `ErrorState` with `onRetry` (or your `errorBuilder`), otherwise
  the `empty` widget (default `EmptyState`). These are `AsyncView`'s states.
  The empty and failure states are not pulled to refresh: use `onRetry`.
- **Next page, `LoadMoreMode.button`** (default). A `LoadMoreButton` ends the
  list while `hasMore`. It is busy until `onLoadMore` completes.
- **Next page, `LoadMoreMode.onScroll`.** `onLoadMore` is called when the
  scroll position is within about one viewport of the end, and when the items
  do not fill the viewport. A `LoadingState` ends the list while it runs. A
  load that added no item is not repeated until `items` changes.
- **Re-entrancy.** `onLoadMore` is never called while a previous call is
  running or `loading` is true.
- **A failing `onLoadMore`.** The error is reported with
  `FlutterError.reportError`, an inline `ErrorState` with a "Retry" button
  replaces the button, and on scroll nothing loads until the retry succeeds.
- **Caller-driven state.** With items, `loading` shows a `LoadingState` at the
  end and `error` an inline `ErrorState` (retry: `onRetry`), for an app whose
  state manager runs the load; no page is requested automatically while
  `error` is set.
- **Pull to refresh.** With `onRefresh`, a `RefreshIndicator` wraps the list
  (always scrollable). The pull resets the "nothing added" guard.
- **Announcement.** When `items` grows after a page was requested, "N more
  loaded" / « N éléments de plus chargés » is announced (string
  `collectionsLoadedMore`, plural). Nothing is announced for an empty page or
  for a refresh.
- `controller` is never disposed; without one the list owns its own.

## Example

```dart
PagedList<Patient>(
  items: state.patients,
  hasMore: state.hasMore,
  loading: state.loading,
  error: state.error,
  onRetry: bloc.reload,
  onLoadMore: bloc.loadNextPage,
  onRefresh: bloc.refresh,
  loadMoreMode: LoadMoreMode.onScroll,
  separatorBuilder: (context, index) => const Divider(height: 1),
  itemBuilder: (context, patient, index) => ListTile(title: Text(patient.name)),
)
```

## Accessibility

The first-load states keep their roles (`status` for loading and empty,
`alert` for the failure). The page announcement is a node with the `status`
role, as a live region everywhere but the web, where the role alone is
announced (see `liveRegionUnderRole`). The "Show more" and "Retry" buttons are
at least 48 dp on every platform, including desktop density. The layout
mirrors in right-to-left and holds at large text sizes. The spinners become a
static icon under reduced motion. Items are plain rows: make each one
reachable and named as you would in a `ListView`.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `items` | `List<T>` | The items loaded so far. |
| `itemBuilder` | `Widget Function(BuildContext, T, int)` | Builds the row of an item. |
| `hasMore` | `bool` | Whether another page exists; default false. Requires `onLoadMore`. |
| `onLoadMore` | `Future<void> Function()?` | Loads the next page; never called while one runs. |
| `onRefresh` | `Future<void> Function()?` | Pull to refresh; `null` disables it. |
| `loading` | `bool` | The first page, or a page the caller loads, is loading. |
| `error` | `Object?` | The failure of the first page, or inline of a page the caller loads. |
| `onRetry` | `Future<void> Function()?` | Retry of the failure shown for `error`. |
| `empty` | `Widget?` | Replaces the default `EmptyState`. |
| `errorBuilder` | `Widget Function(BuildContext, Object)?` | Builds the first-load failure. |
| `loadMoreMode` | `LoadMoreMode` | `button` (default) or `onScroll`. |
| `separatorBuilder` | `IndexedWidgetBuilder?` | Separator between items, none after the last. |
| `padding` | `EdgeInsetsGeometry?` | Padding around the items. |
| `controller` | `ScrollController?` | Never disposed by the list. |
