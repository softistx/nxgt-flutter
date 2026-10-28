# Adaptive layout

`package:nxgt_material/layout.dart` adapts an app to the window it is in,
on the six platforms. It adds no third-party package: it is built on Flutter's
own `NavigationBar`, `NavigationRail`, `NavigationDrawer`, `MediaQuery.sizeOf`
and `SafeArea`.

## Window sizes

The Material 3 classes, by width: compact (under 600 dp), medium (600),
expanded (840), large (1200) and extraLarge (1600). `context.windowSize` reads
the class; `Breakpoints` holds the widths, identical in `@nxgt/material`.

```dart
if (context.windowSize.isAtLeast(WindowSize.expanded)) { /* ... */ }
```

See [WindowSize](../components/window_size.md).

## A shell that follows the window

```dart
AdaptiveShell(destinations: destinations, selectedIndex: i, onSelected: go, body: page)
```

| Window | Navigation |
| --- | --- |
| compact | bottom `NavigationBar` (or a modal drawer, `CompactNavigation.drawer`) |
| medium | `NavigationRail` with labels |
| expanded and wider | standing `NavigationDrawer` |

The body keeps its state while the window is resized, for instance on a
foldable or a desktop window. See [AdaptiveShell](../components/adaptive_shell.md).

## Pages inside the shell

- [PageBody](../components/page_body.md): centred content with gutters per
  window size and a maximum width.
- [ResponsiveGrid](../components/responsive_grid.md): columns by minimum tile
  width.
- [ListDetailLayout](../components/list_detail_layout.md): two panes or one,
  by its own width.

## Keyboard, pointer and safe areas

- **Keyboard:** the shell's destinations are in a focus group in reading order.
  Tab and Shift+Tab move through them, Enter or Space selects. Test it with
  `tester.sendKeyEvent(LogicalKeyboardKey.tab)`.
- **Pointer:** destinations highlight on hover on web and desktop (the cursor
  stays an arrow on desktop, a hand on web, as Flutter's convention is).
- **Safe areas:** the shell reads `MediaQuery.padding`: the navigation keeps
  the insets on its own side and the body the others. In tests, wrap the
  shell in a `MediaQuery` with `copyWith(padding: ...)`.

## Testing a breakpoint

```dart
tester.view
  ..physicalSize = const Size(900, 800)
  ..devicePixelRatio = 1;
addTearDown(tester.view.reset);
```

Phone layouts are checked with phone-size screenshots, not an end-to-end run.
