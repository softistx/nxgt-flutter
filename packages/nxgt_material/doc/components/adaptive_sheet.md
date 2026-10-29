# AdaptiveSheet

Library: `package:nxgt_material/overlays.dart`

A modal sheet that fits the window, shown with `context.showAdaptiveSheet`:
a bottom sheet on a compact window, a side sheet from the medium size up.

"Adaptive" here means the **window size**, not the platform. This is unlike
Flutter's `showAdaptiveDialog`, which picks a Material or Cupertino look by
platform. The size is read from `context.windowSize` when the sheet opens.

## When to use it

For content that is more than a confirmation and less than a screen: filters,
a picker, a short form, details of a row. For a yes or no question use
[ConfirmDialog](confirm_dialog.md). For a sheet that is part of the page
(persistent, not modal) use Material 3's `BottomSheet` or `showBottomSheet`.

## Example

```dart
import 'package:nxgt_material/overlays.dart';

final color = await context.showAdaptiveSheet<Color>(
  title: 'Pick a color',
  builder: (context) => ColorList(
    onPick: (color) => Navigator.pop(context, color),
  ),
);
```

The result is the value the sheet was popped with, or `null` when it was
closed with the close button, Escape, a tap on the barrier or the back gesture.

## Behaviour

- **Compact (under 600 dp).** A modal bottom sheet (`showModalBottomSheet`)
  with a drag handle, inside the safe area, at most 90 % of the window height.
  It is kept above the keyboard: the content is padded by the bottom view
  inset, so a focused field is not hidden.
- **Medium and up.** A side sheet on the end edge (the right in left-to-right
  text, the left in right-to-left), 400 dp wide (the window width if it is
  narrower) and full height, with a slide-in transition and a dimmed barrier.
- **Content.** Below the header, the body scrolls when it is taller than the
  room, also at text scale 2. The builder gets a context under the sheet:
  `Navigator.pop(context, value)` returns a value.
- **Header.** The title and a close button, localized (`actionsClose`).
- **Resize.** The layout is chosen once, when the sheet opens; it is not
  swapped if the window is resized while the sheet is open.

## Accessibility

The title is a semantics header and names the route (`scopesRoute` and
`namesRoute`). The close button is a 48 dp target on every platform, macOS
included, with a localized tooltip and label. The sheet is a modal route, so
focus stays inside it and returns to the control that opened it when it
closes. Escape closes it.

## Properties

`context.showAdaptiveSheet<T>` returns `Future<T?>` and throws without a
`Navigator` above, as `showModalBottomSheet` does.

| Name | Type | Description |
| --- | --- | --- |
| `title` | `String` | The title, also the name of the sheet. Must not be empty. |
| `builder` | `WidgetBuilder` | Builds the body; pop its context to return a value. |

`AdaptiveSheet(title:, child:)` is the content alone (header and scrolling
body), with no surface, handle or route. Use it in a Widgetbook use case or a
golden test; it needs a `Material` ancestor for the close button.
