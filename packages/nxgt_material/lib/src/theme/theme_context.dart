import 'package:flutter/material.dart';
import 'package:nxgt_material/src/theme/motif.dart';
import 'package:nxgt_material/src/theme/radius_scale.dart';
import 'package:nxgt_material/src/theme/theme_fonts.dart';
import 'package:nxgt_material/src/theme/tones.dart';

/// Reads the extensions of the nearest [Theme].
///
/// Each getter throws a [FlutterError] naming the fix when the theme was not
/// built from a `ThemeSpec`.
extension ThemeSpecContext on BuildContext {
  /// The tones of the theme.
  Tones get tones => _read<Tones>(this);

  /// The corner radii of the theme.
  RadiusScale get radii => _read<RadiusScale>(this);

  /// The font families of the theme.
  ThemeFonts get fonts => _read<ThemeFonts>(this);

  /// The background and icon motif of the theme.
  ThemeMotif get motif => _read<ThemeMotif>(this);
}

T _read<T extends ThemeExtension<T>>(BuildContext context) {
  final extension = Theme.of(context).extension<T>();
  if (extension != null) return extension;
  throw FlutterError.fromParts([
    ErrorSummary('The theme has no $T.'),
    ErrorHint(
      'Build the theme with ThemeSpec.light() / dark() '
      '(or a ThemePresets entry), or add a $T to ThemeData.extensions.',
    ),
  ]);
}
