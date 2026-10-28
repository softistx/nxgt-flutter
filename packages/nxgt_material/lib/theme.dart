/// Seeded color schemes, presets, tones, radius and motifs as ThemeExtensions.
///
/// `ThemeSpec` is the Dart `defineTheme` of `@nxgt/material`: a seed colour
/// in, a Material 3 `ThemeData` out, with `Tones`, `RadiusScale`, `ThemeFonts`
/// and `ThemeMotif` as extensions and `context.tones` to read them. The 14
/// presets are in `ThemePresets`.
library;

export 'src/theme/background_preset.dart';
export 'src/theme/contrast.dart';
export 'src/theme/motif.dart';
export 'src/theme/oklch.dart';
export 'src/theme/radius_scale.dart';
export 'src/theme/theme_context.dart';
export 'src/theme/theme_fonts.dart';
export 'src/theme/theme_presets.dart';
export 'src/theme/theme_spec.dart';
export 'src/theme/token_sheet.dart';
export 'src/theme/tone_colors.dart';
export 'src/theme/tone_seed.dart' show ToneSeed;
export 'src/theme/tones.dart' show Tones;
