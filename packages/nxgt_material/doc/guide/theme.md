# Theme

Library: `package:nxgt_material/theme.dart`

A theme from a seed colour: the Dart counterpart of `defineTheme` in the React
library `@nxgt/material`, with the same preset names, seeds, radii and tone
names. It builds a Material 3 `ThemeData` on `ColorScheme.fromSeed` and adds
what Material 3 lacks as `ThemeExtension`s: tones (success, info, warning and
your own), a radius scale, font families and a background motif.

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:nxgt_material/theme.dart';

final spec = ThemePresets.ocean;

MaterialApp(
  theme: spec.light(),
  darkTheme: spec.dark(),
  themeMode: spec.suggestedMode,
  home: const Home(),
);
```

A brand of your own is a `ThemeSpec` with one seed. Seeds are `Oklch(lightness,
chroma, hue)`, the notation of `@nxgt/material`; `Oklch.fromColor(color)` reads
an sRGB `Color`.

```dart
const clinic = ThemeSpec(
  name: 'clinic',
  label: 'Clinic',
  primary: Oklch(0.5, 0.11, 200),
  radius: RadiusScale(base: 12),
);
```

## Presets

`ThemePresets.all` holds the 14 presets of `@nxgt/material`, the default
first: `lavande`, `ocean`, `foret`, `ambre`, `ardoise`, `corail`, `menthe`,
`prune`, `sable`, `slate`, `pink`, `bleumono`, `bluemoon`, `teal`. Look one up
by id with `ThemePresets.byName('ocean')`. Extend one with `copyWith`:

```dart
final school = ThemePresets.ocean.copyWith(
  name: 'school',
  tones: {'maths': const ToneSeed(Oklch(0.5, 0.14, 300))},
);
```

## Tones

A tone is four colours: `color`, `onColor`, `container`, `onContainer`. The
eight of `@nxgt/material` are always there: `primary`, `secondary`,
`tertiary`, `error`, `neutral` (read from the colour scheme) and `success`,
`info`, `warning` (generated). Every pair is solved to WCAG AA text contrast
(4.5:1) in light and dark, and a test checks all of them for every preset.

```dart
final tones = context.tones;

Container(
  color: tones.success.container,
  child: Text('Saved', style: TextStyle(color: tones.success.onContainer)),
);

final maths = tones['maths']; // an app tone, by name; null when unknown
```

- **App tones** go in `ThemeSpec.tones`, by name. The name cannot be one the
  library already uses (`primary`, `strong`, `critical`, ...): see
  the library's reserved list.
- **Replace a status**: give `tones` a `success`, `info` or `warning` seed
  (Teal moves success to hue 145 so it does not read as its primary).
- **Dark seed**: `ToneSeed(light, dark: ...)`. Without it the dark tone starts
  from the light seed lifted to a readable lightness.
- **Secondary and tertiary** seeds also replace the colour scheme's, so
  `colorScheme.secondary` and `context.tones.secondary` are the same colour.

## Under a plain theme

Components of this package read `context.tones`, `context.radii`,
`context.fonts` and `context.motif`, and work under a plain `ThemeData` too:

- `context.radii` falls back to the Material 3 Expressive scale
  (`RadiusScale()`).
- `context.tones` falls back to `Tones.fromScheme(Theme.of(context).colorScheme)`:
  the same AA-solved status tones a `ThemeSpec` generates, with primary, error
  and neutral read from the colour scheme. It is cached per `ColorScheme`.
- `context.fonts` falls back to `const ThemeFonts()` and `context.motif` to
  `ThemeMotif.none`, the `ThemeSpec` defaults.
- `Tones[name]` returns `null` for a name that is neither a named tone nor an
  app tone.

## Radius, fonts, motif

```dart
context.radii.base;        // the theme's own radius, in dp
context.radii.xl;          // the M3 Expressive scale: xs 4 ... xxl 48
context.fonts.monoStyle(); // code and figures
context.motif.preset;      // BackgroundPreset.waves
```

- **Radius**: `RadiusScale(base: 12)`. `item` follows `base` unless set. The
  theme's `Card` uses `item`; other Material 3 shapes stay Material 3's.
- **Fonts**: family names only; the app loads the files in its pubspec.
  `sans: null` is the platform font. `heading` styles the display and headline
  text.
- **Motif**: the data of a theme's `background` in `@nxgt/material` (a preset
  id among the 50 of `BackgroundPreset`, tone, intensity, density, shapes). The
  package describes the decoration; the app draws it behind a hero, an empty
  state or a sign-in screen.

## Token sheet

`TokenSheet` draws every tone and the radius scale of the current theme. Use it
to preview a theme, in Widgetbook or in a golden:

```dart
Theme(data: school.dark(), child: const TokenSheet());
```

## Limits

- `copyWith` cannot clear a nullable field: `label`, `secondary` and
  `tertiary` of `ThemeSpec` and `moonPosition` of `ThemeMotif` keep their value
  when `null` is passed. Build a new spec to drop one.
- `TokenSheet` is a catalogue and development widget. Its swatches have
  semantics labels (`success color`, `success container`), in English, not
  localised.
- `wcagContrast(a, b)` is the WCAG 2.x contrast ratio the tests use.

## What differs from `@nxgt/material`

- No CSS: there is no `themeToCss`, boot script or `data-nxgt-theme`.
- Neutrals come from `ColorScheme.fromSeed`: no `neutral` tint option and no
  shared "night" for dark.
- The `tokens` override and `extends` object are replaced by `copyWith`.
- Backgrounds are described, not drawn.
