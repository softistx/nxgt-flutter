import 'package:nxgt_material/src/theme/background_preset.dart';
import 'package:nxgt_material/src/theme/motif.dart';
import 'package:nxgt_material/src/theme/oklch.dart';
import 'package:nxgt_material/src/theme/radius_scale.dart';
import 'package:nxgt_material/src/theme/theme_spec.dart';
import 'package:nxgt_material/src/theme/tone_seed.dart';

/// Sable.
const ThemeSpec sablePreset = ThemeSpec(
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
const ThemeSpec slatePreset = ThemeSpec(
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
