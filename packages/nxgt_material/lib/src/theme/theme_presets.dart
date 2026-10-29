import 'package:nxgt_material/src/theme/motif.dart';
import 'package:nxgt_material/src/theme/theme_presets_cool.dart';
import 'package:nxgt_material/src/theme/theme_presets_neutral.dart';
import 'package:nxgt_material/src/theme/theme_presets_warm.dart';
import 'package:nxgt_material/src/theme/theme_spec.dart';

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
  static const ThemeSpec lavande = lavandePreset;

  /// Océan.
  static const ThemeSpec ocean = oceanPreset;

  /// Forêt.
  static const ThemeSpec foret = foretPreset;

  /// Ambre.
  static const ThemeSpec ambre = ambrePreset;

  /// Ardoise.
  static const ThemeSpec ardoise = ardoisePreset;

  /// Corail.
  static const ThemeSpec corail = corailPreset;

  /// Menthe.
  static const ThemeSpec menthe = menthePreset;

  /// Prune.
  static const ThemeSpec prune = prunePreset;

  /// Sable.
  static const ThemeSpec sable = sablePreset;

  /// Slate.
  static const ThemeSpec slate = slatePreset;

  /// Pink.
  static const ThemeSpec pink = pinkPreset;

  /// Bleu mono.
  static const ThemeSpec bleumono = bleumonoPreset;

  /// Blue moon.
  static const ThemeSpec bluemoon = bluemoonPreset;

  /// Teal.
  static const ThemeSpec teal = tealPreset;

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
