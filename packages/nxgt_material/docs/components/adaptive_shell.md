# AdaptiveShell

Library: `package:nxgt_material/layout.dart`

The frame of an app: its destinations as a navigation bar on a compact window,
a rail on a medium one and a standing drawer on an expanded one and wider.
`ShellDestination` describes a destination; `CompactNavigation` picks the
compact style.

## When to use it

Once, at the root of a screen with two to five top-level places. It builds
`NavigationBar`, `NavigationRail` and `NavigationDrawer` for you and switches
by [WindowSize](window_size.md), so there is no `LayoutBuilder` to write. Keep
using those widgets directly when you need one of them on its own.

## Example

```dart
AdaptiveShell(
  destinations: const [
    ShellDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    ShellDestination(
      icon: Icon(Icons.inbox_outlined),
      label: 'Inbox',
      badge: Badge(label: Text('3')),
    ),
  ],
  selectedIndex: index,
  onSelected: (i) => setState(() => index = i),
  body: pages[index],
)
```

A drawer on a phone instead of a bar (an app bar with a menu button, labelled
"Open navigation", appears; the drawer has a "Close navigation" button):

```dart
AdaptiveShell(
  compactNavigation: CompactNavigation.drawer,
  title: const Text('Acme'),
  /* ... */
)
```

## Accessibility

- Each destination reports its label, "Tab n of m" and its selected state, as
  Flutter's own destinations do, and is at least 48 dp tall (the expanded
  drawer's tiles are 56 dp; an extended rail was avoided because its
  destinations are 44 dp).
- The navigation is a labelled region (`layoutNavigation`, "Navigation") and
  its destinations take keyboard focus in reading order: Tab moves through
  them, Enter or Space selects, Shift+Tab goes back. The body follows.
- The menu and close buttons of the drawer carry the localized
  `layoutOpenNavigation` and `layoutCloseNavigation` labels.
- Hover and focus highlights come from the Material destinations, so a mouse
  and a keyboard are served on web and desktop.
- Notches and system bars: the body and the navigation stay inside the safe
  area (the rail and the drawer keep the left inset, the body keeps the top,
  bottom and right ones, and a bar keeps the bottom one).

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `destinations` | `List<ShellDestination>` | The places, at least two. |
| `selectedIndex` | `int` | The current destination. |
| `onSelected` | `ValueChanged<int>` | Called with the picked index. |
| `body` | `Widget` | The current screen. |
| `compactNavigation` | `CompactNavigation` | `bar` (default) or `drawer` on a compact window. |
| `title` | `Widget?` | Title of a shared app bar. |
| `floatingActionButton` | `Widget?` | Action button over the body. |

`ShellDestination`: `icon`, `label`, `selectedIcon`, `badge`.

Errors: [AdaptiveShell needs at least two destinations.](../troubleshooting.md)
and [AdaptiveShell.selectedIndex is out of range.](../troubleshooting.md).
