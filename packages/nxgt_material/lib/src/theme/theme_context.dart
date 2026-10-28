import 'package:flutter/material.dart';
import 'package:nxgt_material/src/theme/motif.dart';
import 'package:nxgt_material/src/theme/radius_scale.dart';
import 'package:nxgt_material/src/theme/theme_fonts.dart';
import 'package:nxgt_material/src/theme/tones.dart';

/// Reads the extensions of the nearest [Theme].
///
/// Every getter falls back when the theme was not built from a `ThemeSpec`,
/// so a component can use them under any theme: [tones] are generated from the
/// theme's colour scheme (the same AA-solved tones a `ThemeSpec` would give
/// for that scheme), [radii] are the Material 3 Expressive defaults, [fonts]
/// are the `ThemeSpec` default (the platform's fonts) and [motif] is
/// `ThemeMotif.none`.
extension ThemeSpecContext on BuildContext {
  /// The tones of the theme.
  ///
  /// Without a `Tones` extension they are generated from the theme's
  /// [ColorScheme] and cached per scheme, so reading them in `build` is cheap.
  Tones get tones {
    final theme = Theme.of(this);
    return theme.extension<Tones>() ?? _fallbackTones(theme.colorScheme);
  }

  /// The corner radii of the theme.
  RadiusScale get radii =>
      Theme.of(this).extension<RadiusScale>() ?? const RadiusScale();

  /// The font families of the theme.
  ThemeFonts get fonts =>
      Theme.of(this).extension<ThemeFonts>() ?? const ThemeFonts();

  /// The background and icon motif of the theme.
  ThemeMotif get motif =>
      Theme.of(this).extension<ThemeMotif>() ?? ThemeMotif.none;
}

final _fallbackCache = Expando<Tones>('nxgt_material fallback tones');

Tones _fallbackTones(ColorScheme scheme) =>
    _fallbackCache[scheme] ??= Tones.fromScheme(scheme);
