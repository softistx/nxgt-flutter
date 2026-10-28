# ListDetailLayout

Library: `package:nxgt_material/layout.dart`

A list and its detail side by side when there is room, one at a time when
there is not. It follows its own width: both panes show above 648 dp
(`Breakpoints.singlePane`, as `ListDetailsLayout` of `@nxgt/material`), the
list at 360 dp and the detail on a rounded surface filling the rest.

## When to use it

For a master-detail screen (mail, invoices, settings). On a narrow layout the
detail replaces the list while `showDetail` is true and the system back
gesture calls `onBack`, where the app clears its selection.

## Example

```dart
ListDetailLayout(
  showDetail: selected != null,
  onBack: () => setState(() => selected = null),
  list: InvoiceList(onTap: (i) => setState(() => selected = i)),
  detail: selected == null
      ? const EmptyState()
      : InvoiceDetail(selected!),
)
```

## Accessibility

Each pane is its own semantics container, so a screen reader moves between
them as two regions; only the visible pane exists on a narrow layout, so
nothing hidden can be focused. The back gesture and the platform back button
return to the list. Put your own back button in the detail if you want a
visible one.

## Back navigation

- **Android 14 and later:** for the predictive back animation, set
  `android:enableOnBackInvokedCallback="true"` on the `<application>` (or the
  activity) in `AndroidManifest.xml`. Without it the back button still calls
  `onBack`, with no animation.
- **iOS:** the swipe-back gesture is off while the detail is shown on a narrow
  layout, because the layout intercepts the pop; offer a back button in the
  detail that calls the same function as `onBack`.
- It needs a bounded width: inside a horizontal scroll view or an unconstrained
  `Row` it throws (see [troubleshooting](../troubleshooting.md)).
- Both panes keep their state when the layout crosses 648 dp, and the hidden
  pane of a narrow layout stays alive but is not focusable or announced.
- **Side effects of keeping the hidden pane built:** its `initState` work
  (fetches) still runs, and your detail builder runs while nothing is selected
  (render a placeholder, as the example does); and two panes cannot both use
  the `PrimaryScrollController`, so give one of the two scroll views its own
  `ScrollController`.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `list` | `Widget` | The list pane. |
| `detail` | `Widget` | The detail pane. |
| `showDetail` | `bool` | Whether the detail is the current view on a narrow layout. |
| `onBack` | `VoidCallback?` | Called when the user goes back from a narrow detail. |
| `listWidth` | `double` | Width of the list pane when both show. Defaults to 360. |
