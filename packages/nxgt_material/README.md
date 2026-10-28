# nxgt_material

Material 3 components for Flutter that fill what the framework leaves out:
adaptive layout, fields and forms, feedback states, themes. Intent-named,
accessible, French and English.

> Status: 0.0.1, the package skeleton. Components arrive with 0.1; see the
> [roadmap](docs/roadmap.md).

Runs on Android, iOS, web, macOS, Windows and Linux.

## Install

```sh
flutter pub add nxgt_material
```

## Use

One library per category. Import the one you need, or the barrel:

```dart
import 'package:nxgt_material/fields.dart';
// or everything:
import 'package:nxgt_material/nxgt_material.dart';
```

| Library | What is in it |
| --- | --- |
| `actions.dart` | Buttons and menus that trigger something |
| `collections.dart` | Lists, tables, grids and trees of records |
| `dates.dart` | Date, time and range pickers and their formatting |
| `display.dart` | Cards, stats, badges, avatars |
| `feedback.dart` | Empty, loading and error states, toasts, banners, progress |
| `fields.dart` | Single-value inputs built on `FormField` |
| `forms.dart` | Form scaffolding: sections, validation summary, submit bar |
| `layout.dart` | Adaptive shell, breakpoints, pane layouts, spacing |
| `media.dart` | Images, galleries, players, file previews |
| `overlays.dart` | Dialogs, sheets, popovers, tooltips |
| `selection.dart` | Dropdowns, segmented and chip groups |
| `theme.dart` | Seeded color schemes, presets, tones, radius, motifs |

## Theme

A Material 3 theme from a seed colour, with the presets, tones, radius and
motifs of the React library `@nxgt/material`:

```dart
import 'package:nxgt_material/theme.dart';

MaterialApp(
  theme: ThemePresets.ocean.light(),
  darkTheme: ThemePresets.ocean.dark(),
);

// anywhere below:
final done = context.tones.success; // color, onColor, container, onContainer
```

See the [theme guide](docs/guide/theme.md).

## Localization

French and English strings for every component. Add one delegate:

```dart
MaterialApp(
  localizationsDelegates: const [
    NxgtMaterialLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: NxgtMaterialLocalizations.supportedLocales,
);
```

Any other locale falls back to English; single strings can be overridden. See
the [localization guide](docs/guide/localization.md).

## Naming rule

- **No `nxgt` prefix.** A component is called by what it is for: `StatCard`,
  `EmailField`, `ConfirmDialog`.
- **Never redefine an M3 widget name.** Flutter's Material 3 widgets stay the
  base; this package never re-wraps `FilledButton`, `Card` or `TextField` under
  its own name. It adds what is missing, under an intent name.

## Documentation

- [Theme](docs/guide/theme.md)
- [Localization](docs/guide/localization.md)
- [Roadmap](docs/roadmap.md)
- [Troubleshooting](docs/troubleshooting.md)
- `docs/components/`: one page per component
- Live catalogue: Widgetbook, published on GitHub Pages from `develop`.

## License

MIT, see [LICENSE](LICENSE).
