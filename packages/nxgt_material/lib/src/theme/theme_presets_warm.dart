import 'package:nxgt_material/src/theme/background_preset.dart';
import 'package:nxgt_material/src/theme/motif.dart';
import 'package:nxgt_material/src/theme/oklch.dart';
import 'package:nxgt_material/src/theme/radius_scale.dart';
import 'package:nxgt_material/src/theme/theme_fonts.dart';
import 'package:nxgt_material/src/theme/theme_spec.dart';
import 'package:nxgt_material/src/theme/tone_seed.dart';

/// Ambre.
const ThemeSpec ambrePreset = ThemeSpec(
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

/// Corail.
const ThemeSpec corailPreset = ThemeSpec(
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

/// Pink.
const ThemeSpec pinkPreset = ThemeSpec(
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

/// Prune.
const ThemeSpec prunePreset = ThemeSpec(
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
