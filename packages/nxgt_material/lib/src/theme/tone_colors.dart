import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:nxgt_material/src/theme/contrast.dart';
import 'package:nxgt_material/src/theme/oklch.dart';

/// The four colours of one tone in one brightness.
///
/// The pairs [color] on [onColor] and [container] on [onContainer] meet WCAG
/// AA text contrast (4.5:1) for every tone this package generates.
@immutable
class ToneColors {
  /// Creates a tone from its four colours.
  const new({
    required this.color,
    required this.onColor,
    required this.container,
    required this.onContainer,
  });

  /// Derives a tone from [seed] for [brightness], solving each lightness so
  /// that both pairs reach AA.
  factory fromSeed(Oklch seed, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final onColor = dark
        ? Oklch(0.2, seed.c * 0.3, seed.h).toColor()
        : const Color(0xFFFFFFFF);
    final color = _reach(seed, onColor, lighter: dark);
    final container = dark
        ? Oklch(0.32, seed.c * 0.5, seed.h).toColor()
        : Oklch(0.93, seed.c * 0.35, seed.h).toColor();
    final onContainer = _reach(
      dark
          ? Oklch(0.9, seed.c * 0.35, seed.h)
          : Oklch(0.3, seed.c * 0.6, seed.h),
      container,
      lighter: dark,
    );
    return ToneColors(
      color: color,
      onColor: onColor,
      container: container,
      onContainer: onContainer,
    );
  }

  /// The strong fill, for a badge, a bar or an icon.
  final Color color;

  /// The text and icons drawn on [color].
  final Color onColor;

  /// The soft fill, for a banner or a chip.
  final Color container;

  /// The text and icons drawn on [container].
  final Color onContainer;

  /// The pairs of this tone as `(foreground, background)`, for contrast checks.
  List<(Color, Color)> get pairs => [
    (onColor, color),
    (onContainer, container),
  ];

  /// This tone with the given colours replaced.
  ToneColors copyWith({
    Color? color,
    Color? onColor,
    Color? container,
    Color? onContainer,
  }) => ToneColors(
    color: color ?? this.color,
    onColor: onColor ?? this.onColor,
    container: container ?? this.container,
    onContainer: onContainer ?? this.onContainer,
  );

  /// Linear interpolation from this tone to [other].
  ToneColors lerp(ToneColors other, double t) => ToneColors(
    color: Color.lerp(color, other.color, t)!,
    onColor: Color.lerp(onColor, other.onColor, t)!,
    container: Color.lerp(container, other.container, t)!,
    onContainer: Color.lerp(onContainer, other.onContainer, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is ToneColors &&
      other.color == color &&
      other.onColor == onColor &&
      other.container == container &&
      other.onContainer == onContainer;

  @override
  int get hashCode => Object.hash(color, onColor, container, onContainer);
}

/// Moves [start] away from [against] (lighter or darker) until the contrast
/// is 4.5:1, falling back to black or white.
Color _reach(Oklch start, Color against, {required bool lighter}) {
  var step = start;
  for (var i = 0; i < 100; i++) {
    final color = step.toColor();
    if (wcagContrast(color, against) >= 4.5) return color;
    final next = step.l + (lighter ? 0.01 : -0.01);
    if (next < 0 || next > 1) break;
    step = step.copyWith(l: next);
  }
  return lighter ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
}
