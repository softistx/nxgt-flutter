# LoadMoreButton

Library: `package:nxgt_material/actions.dart`

The "Show more" button at the end of a paginated list: an outlined
`AsyncButton` that disappears when there is nothing more to load.

## When to use it

Under a list with cursor or page pagination where the user asks for the next
page. For infinite scrolling, load on scroll instead.

## Example

```dart
LoadMoreButton(
  hasMore: page.hasNext,
  onPressed: () => controller.loadNextPage(),
)
```

## Accessibility

Same as [AsyncButton](async_button.md): a button named by its label (the
localized `actionsShowMore` by default), "Loading" as its value while the next
page loads, a 48 dp target, focus kept while busy.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `onPressed` | `Future<void> Function()` | Loads the next page; busy until it completes. |
| `hasMore` | `bool` | When false nothing is built. Defaults to true. |
| `label` | `String?` | Overrides the localized "Show more". |
