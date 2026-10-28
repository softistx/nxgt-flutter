## Unreleased

- `theme.dart`: `ThemeSpec` builds a Material 3 light and dark `ThemeData` from a seed colour (`ColorScheme.fromSeed`), with the 14 presets of `@nxgt/material` (`ThemePresets`), AA-solved `Tones` (primary, secondary, tertiary, success, info, warning, error, neutral, and app tones), `RadiusScale`, `ThemeFonts` and `ThemeMotif` as `ThemeExtension`s, `context.tones` / `radii` / `fonts` / `motif`, and a `TokenSheet` widget.

- `l10n.dart`: French and English strings (`gen-l10n`, ARBs in `lib/l10n/`) for actions, field validation, feedback states and adaptive navigation. `NxgtMaterialLocalizationsDelegate` (falls back to English for any other locale, takes `reword:` to override strings through a `NxgtMaterialLocalizationsWrapper` subclass), `NxgtMaterialLocalizations.supportedLocales` and `context.materialL10n`. Widgetbook gets a locale addon.

## 0.0.1

- Package skeleton: one library per category, no component yet.
