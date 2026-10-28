# WindowSize and Breakpoints

Library: `package:nxgt_material/layout.dart`

The Material 3 window size classes and `context.windowSize`, the one place
that decides what "compact" or "expanded" means. `Breakpoints` holds the
widths, the same as `@nxgt/material`.

## When to use it

Whenever a layout depends on the window: choose between a bar and a rail,
one pane or two, one column or three. Read the class, never compare a raw
width, so every screen agrees. For the space a widget is *given* (a column, a
dialog) use `LayoutBuilder`, as [ListDetailLayout](list_detail_layout.md) does.

## Example

```dart
@override
Widget build(BuildContext context) {
  return switch (context.windowSize) {
    WindowSize.compact => const PhoneLayout(),
    WindowSize.medium => const TabletLayout(),
    _ => const DesktopLayout(),
  };
}

if (context.windowSize.isAtLeast(WindowSize.expanded)) { /* two panes */ }
final size = WindowSize.fromWidth(constraints.maxWidth);
```

| Class | From (dp) | Typical window |
| --- | --- | --- |
| `compact` | 0 | phone in portrait |
| `medium` | 600 | tablet in portrait, foldable |
| `expanded` | 840 | tablet in landscape, small desktop window |
| `large` | 1200 | desktop |
| `extraLarge` | 1600 | large desktop |

## Accessibility

None of its own. It reads `MediaQuery.sizeOf`, so a layout follows the window
and not the text scale; check large text on a compact window as well.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `WindowSize.fromWidth(double)` | `WindowSize` | The class of a width. |
| `WindowSize.minWidth` | `double` | The smallest width of the class. |
| `WindowSize.isAtLeast(other)` | `bool` | Whether the class is `other` or wider. |
| `context.windowSize` | `WindowSize` | The class of the window; listens to the size only. |
| `Breakpoints.medium`, `expanded`, `large`, `extraLarge` | `double` | 600, 840, 1200, 1600. |
| `Breakpoints.singlePane` | `double` | 648, the width up to which a list-detail shows one pane. |
