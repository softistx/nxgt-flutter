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
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nxgt_material/l10n.dart';
import 'package:nxgt_material/layout.dart';

void main() => runApp(
  MaterialApp(
    localizationsDelegates: const [
      NxgtMaterialLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: NxgtMaterialLocalizations.supportedLocales,
    home: const Home(),
  ),
);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      destinations: const [
        ShellDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        ShellDestination(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
      ],
      selectedIndex: index,
      onSelected: (i) => setState(() => index = i),
      body: SingleChildScrollView(
        child: PageBody(
          child: ResponsiveGrid(
            children: [
              for (var i = 0; i < 6; i++)
                Card(child: SizedBox(height: 80, child: Center(child: Text('Tile $i')))),
            ],
          ),
        ),
      ),
    );
  }
}
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
  Flutter's own destinations do, and is at least 48 dp tall. The standing
  drawer (tiles 56 dp) is used on expanded windows because Material's
  *extended* `NavigationRail` has destinations only 44 dp tall, under the
  48 dp target.
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
| `title` | `Widget?` | Title of the shared app bar. Without it (and `appBar`) there is none, except with `CompactNavigation.drawer`. |
| `appBar` | `PreferredSizeWidget?` | An app bar of your own; overrides `title` and `actions`. With the drawer style an `AppBar` adds Material's drawer button unless you set `leading`. |
| `actions` | `List<Widget>?` | Actions of the app bar built from `title`. |
| `floatingActionButton` | `Widget?` | Action button over the body. |
| `floatingActionButtonLocation` | `FloatingActionButtonLocation?` | Where it sits. |
| `bottomSheet` | `Widget?` | A persistent bottom sheet, as `Scaffold.bottomSheet`. |

`ShellDestination`:

| Name | Type | Description |
| --- | --- | --- |
| `icon` | `Widget` | Required. The icon; also the selected one without `selectedIcon`. |
| `label` | `String` | Required. Spoken by screen readers, shown by the rail and drawer. |
| `selectedIcon` | `Widget?` | Icon of the selected destination. Defaults to `icon`. |
| `badge` | `Widget?` | A badge over the icon, such as `Badge`. Defaults to none. |

`CompactNavigation`: `bar` (default) or `drawer`.

## Behaviour to know

- The shell builds a `Scaffold`. A screen's own `Scaffold` (with its own app
  bar) can nest inside `body`; with a shared `title` or `appBar` you will see
  two bars, so use one or the other.
- The `body` keeps its state (scroll offset, typed text) when the window
  crosses 600 or 840 dp.
- An open modal drawer closes when the window stops being compact.
- Safe-area insets follow the text direction: the navigation takes the start
  inset, the body the end one.

Errors: [AdaptiveShell needs at least two destinations.](../troubleshooting.md)
and [AdaptiveShell.selectedIndex is out of range.](../troubleshooting.md).
