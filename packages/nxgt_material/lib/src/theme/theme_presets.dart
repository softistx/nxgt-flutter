import 'package:flutter/material.dart';
import 'package:nxgt_material/src/theme/background_preset.dart';
import 'package:nxgt_material/src/theme/motif.dart';
import 'package:nxgt_material/src/theme/oklch.dart';
import 'package:nxgt_material/src/theme/radius_scale.dart';
import 'package:nxgt_material/src/theme/theme_fonts.dart';
import 'package:nxgt_material/src/theme/theme_spec.dart';
import 'package:nxgt_material/src/theme/tone_seed.dart';

/// The 14 presets of `@nxgt/material`, by the same ids, seeds and radii.
///
/// Lavande is the default. Font families are the names of the web stacks'
/// first family (`Inter`, `SF Pro Rounded`); the platform font when the
/// stack was the system one. Backgrounds are described by [ThemeMotif]; the
/// app draws them.
abstract final class ThemePresets {
  /// The default preset.
  static const ThemeSpec defaultPreset = lavande;

  /// Lavande.
  static const lavande = ThemeSpec(
    name: 'lavande',
    label: 'Lavande',
    primary: Oklch(0.46, 0.1135, 276.35),
    secondary: ToneSeed(Oklch(0.48, 0.1135, 245.65)),
    tertiary: ToneSeed(Oklch(0.4591, 0.1864, 310.75)),
    fonts: ThemeFonts(sans: 'Inter'),
  );

  /// Océan.
  static const ocean = ThemeSpec(
    name: 'ocean',
    label: 'Océan',
    primary: Oklch(0.5, 0.12, 228),
    secondary: ToneSeed(Oklch(0.52, 0.09, 192)),
    tertiary: ToneSeed(Oklch(0.5, 0.13, 268)),
    radius: RadiusScale(base: 12),
    fonts: ThemeFonts(sans: 'Inter'),
    motif: ThemeMotif(
      preset: BackgroundPreset.waves,
      tone: MotifTone.mixed,
      intensity: MotifIntensity.subtle,
    ),
  );

  /// Forêt.
  static const foret = ThemeSpec(
    name: 'foret',
    label: 'Forêt',
    primary: Oklch(0.48, 0.1, 152),
    secondary: ToneSeed(Oklch(0.5, 0.08, 118)),
    tertiary: ToneSeed(Oklch(0.5, 0.1, 55)),
    radius: RadiusScale(base: 8),
    motif: ThemeMotif(
      preset: BackgroundPreset.leaves,
      intensity: MotifIntensity.subtle,
      density: MotifDensity.low,
      rotate: true,
    ),
  );

  /// Ambre.
  static const ambre = ThemeSpec(
    name: 'ambre',
    label: 'Ambre',
    primary: Oklch(0.52, 0.13, 48),
    secondary: ToneSeed(Oklch(0.5, 0.09, 95)),
    tertiary: ToneSeed(Oklch(0.5, 0.14, 350)),
    radius: RadiusScale(base: 14),
    fonts: ThemeFonts(sans: 'SF Pro Rounded'),
    motif: ThemeMotif(
      preset: BackgroundPreset.topography,
      tone: MotifTone.mixed,
      intensity: MotifIntensity.subtle,
    ),
  );

  /// Ardoise.
  static const ardoise = ThemeSpec(
    name: 'ardoise',
    label: 'Ardoise',
    primary: Oklch(0.45, 0.065, 252),
    secondary: ToneSeed(Oklch(0.48, 0.05, 215)),
    tertiary: ToneSeed(Oklch(0.48, 0.1, 290)),
    radius: RadiusScale(base: 6),
    fonts: ThemeFonts(sans: 'Inter'),
    motif: ThemeMotif(
      preset: BackgroundPreset.shapes,
      tone: MotifTone.neutral,
      intensity: MotifIntensity.subtle,
      shapes: ['ring', 'plus', 'line', 'square'],
      density: MotifDensity.low,
      fill: MotifFill.outline,
    ),
  );

  /// Corail.
  static const corail = ThemeSpec(
    name: 'corail',
    label: 'Corail',
    primary: Oklch(0.58, 0.17, 35),
    secondary: ToneSeed(Oklch(0.52, 0.1, 70)),
    tertiary: ToneSeed(Oklch(0.5, 0.1, 200)),
    radius: RadiusScale(base: 16),
    fonts: ThemeFonts(sans: 'SF Pro Rounded'),
    motif: ThemeMotif(
      preset: BackgroundPreset.confettiGrid,
      tone: MotifTone.mixed,
      shapes: ['circle', 'ring', 'triangle', 'square', 'plus'],
      rotate: true,
    ),
  );

  /// Menthe.
  static const menthe = ThemeSpec(
    name: 'menthe',
    label: 'Menthe',
    primary: Oklch(0.5, 0.105, 168),
    secondary: ToneSeed(Oklch(0.5, 0.09, 205)),
    tertiary: ToneSeed(Oklch(0.52, 0.11, 120)),
    radius: RadiusScale(base: 16),
    motif: ThemeMotif(preset: BackgroundPreset.bubbles, tone: MotifTone.mixed),
  );

  /// Prune.
  static const prune = ThemeSpec(
    name: 'prune',
    label: 'Prune',
    primary: Oklch(0.42, 0.15, 330),
    secondary: ToneSeed(Oklch(0.5, 0.1, 355)),
    tertiary: ToneSeed(Oklch(0.55, 0.1, 85)),
    radius: RadiusScale(base: 8),
    fonts: ThemeFonts(sans: 'Inter'),
    motif: ThemeMotif(
      preset: BackgroundPreset.nightSky,
      density: MotifDensity.low,
    ),
  );

  /// Sable.
  static const sable = ThemeSpec(
    name: 'sable',
    label: 'Sable',
    primary: Oklch(0.5, 0.06, 70),
    secondary: ToneSeed(Oklch(0.5, 0.05, 45)),
    tertiary: ToneSeed(Oklch(0.5, 0.07, 150)),
    radius: RadiusScale(base: 8),
    motif: ThemeMotif(
      preset: BackgroundPreset.linen,
      tone: MotifTone.neutral,
      intensity: MotifIntensity.subtle,
    ),
  );

  /// Slate.
  static const slate = ThemeSpec(
    name: 'slate',
    label: 'Slate',
    primary: Oklch(0.4, 0.025, 258),
    secondary: ToneSeed(Oklch(0.48, 0.02, 230)),
    tertiary: ToneSeed(Oklch(0.46, 0.045, 275)),
    radius: RadiusScale(base: 4),
    motif: ThemeMotif(
      preset: BackgroundPreset.graphPaper,
      tone: MotifTone.neutral,
      intensity: MotifIntensity.subtle,
    ),
  );

  /// Pink.
  static const pink = ThemeSpec(
    name: 'pink',
    label: 'Pink',
    primary: Oklch(0.55, 0.2, 345),
    secondary: ToneSeed(Oklch(0.5, 0.14, 320)),
    tertiary: ToneSeed(Oklch(0.5, 0.1, 200)),
    radius: RadiusScale(base: 20),
    fonts: ThemeFonts(sans: 'SF Pro Rounded'),
    motif: ThemeMotif(
      preset: BackgroundPreset.shapes,
      tone: MotifTone.mixed,
      shapes: ['circle', 'm3-flower', 'm3-cookie-6', 'heart'],
      fill: MotifFill.filled,
    ),
  );

  /// Bleu mono.
  static const bleumono = ThemeSpec(
    name: 'bleumono',
    label: 'Bleu mono',
    primary: Oklch(0.46, 0.13, 255),
    secondary: ToneSeed(Oklch(0.55, 0.06, 255)),
    tertiary: ToneSeed(Oklch(0.38, 0.17, 255), dark: Oklch(0.82, 0.09, 255)),
    radius: RadiusScale(base: 8),
    fonts: ThemeFonts(sans: 'Inter'),
    motif: ThemeMotif(
      preset: BackgroundPreset.chevrons,
      intensity: MotifIntensity.subtle,
    ),
  );

  /// Blue moon.
  static const bluemoon = ThemeSpec(
    name: 'bluemoon',
    label: 'Blue moon',
    primary: Oklch(0.45, 0.12, 265),
    secondary: ToneSeed(Oklch(0.55, 0.02, 250)),
    tertiary: ToneSeed(Oklch(0.62, 0.08, 290)),
    radius: RadiusScale(base: 12),
    fonts: ThemeFonts(sans: 'Inter'),
    motif: ThemeMotif(
      preset: BackgroundPreset.moon,
      tone: MotifTone.mixed,
      intensity: MotifIntensity.subtle,
      moonPosition: Offset(0.8, 0.34),
    ),
    suggestedMode: ThemeMode.dark,
  );

  /// Teal.
  static const teal = ThemeSpec(
    name: 'teal',
    label: 'Teal',
    primary: Oklch(0.5, 0.105, 185),
    secondary: ToneSeed(Oklch(0.52, 0.09, 215)),
    tertiary: ToneSeed(Oklch(0.52, 0.12, 60)),
    tones: {
      'success': ToneSeed(
        Oklch(0.46, 0.118, 145),
        dark: Oklch(0.6, 0.118, 145),
      ),
    },
    radius: RadiusScale(base: 8),
    motif: ThemeMotif(preset: BackgroundPreset.hexagons),
  );

  /// Every preset, the default first.
  static const List<ThemeSpec> all = [
    lavande,
    ocean,
    foret,
    ambre,
    ardoise,
    corail,
    menthe,
    prune,
    sable,
    slate,
    pink,
    bleumono,
    bluemoon,
    teal,
  ];

  /// The preset called [name], or `null`.
  static ThemeSpec? byName(String name) {
    for (final preset in all) {
      if (preset.name == name) return preset;
    }
    return null;
  }
}
