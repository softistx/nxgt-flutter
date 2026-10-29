import 'package:flutter/material.dart';
import 'package:nxgt_material/src/theme/background_preset.dart';
import 'package:nxgt_material/src/theme/motif.dart';
import 'package:nxgt_material/src/theme/oklch.dart';
import 'package:nxgt_material/src/theme/radius_scale.dart';
import 'package:nxgt_material/src/theme/theme_fonts.dart';
import 'package:nxgt_material/src/theme/theme_spec.dart';
import 'package:nxgt_material/src/theme/tone_seed.dart';

/// Lavande.
const ThemeSpec lavandePreset = ThemeSpec(
  name: 'lavande',
  label: 'Lavande',
  primary: Oklch(0.46, 0.1135, 276.35),
  secondary: ToneSeed(Oklch(0.48, 0.1135, 245.65)),
  tertiary: ToneSeed(Oklch(0.4591, 0.1864, 310.75)),
  fonts: ThemeFonts(sans: 'Inter'),
);

/// Océan.
const ThemeSpec oceanPreset = ThemeSpec(
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
const ThemeSpec foretPreset = ThemeSpec(
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

/// Menthe.
const ThemeSpec menthePreset = ThemeSpec(
  name: 'menthe',
  label: 'Menthe',
  primary: Oklch(0.5, 0.105, 168),
  secondary: ToneSeed(Oklch(0.5, 0.09, 205)),
  tertiary: ToneSeed(Oklch(0.52, 0.11, 120)),
  radius: RadiusScale(base: 16),
  motif: ThemeMotif(preset: BackgroundPreset.bubbles, tone: MotifTone.mixed),
);

/// Ardoise.
const ThemeSpec ardoisePreset = ThemeSpec(
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

/// Bleu mono.
const ThemeSpec bleumonoPreset = ThemeSpec(
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
const ThemeSpec bluemoonPreset = ThemeSpec(
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
const ThemeSpec tealPreset = ThemeSpec(
  name: 'teal',
  label: 'Teal',
  primary: Oklch(0.5, 0.105, 185),
  secondary: ToneSeed(Oklch(0.52, 0.09, 215)),
  tertiary: ToneSeed(Oklch(0.52, 0.12, 60)),
  tones: {
    'success': ToneSeed(Oklch(0.46, 0.118, 145), dark: Oklch(0.6, 0.118, 145)),
  },
  radius: RadiusScale(base: 8),
  motif: ThemeMotif(preset: BackgroundPreset.hexagons),
);
