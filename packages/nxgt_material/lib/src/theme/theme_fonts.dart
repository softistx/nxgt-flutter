import 'package:flutter/material.dart';

/// The font families of a theme.
///
/// Names only: the app loads the files (a `fonts:` entry in its pubspec, or
/// `google_fonts`). A `null` family is the platform's. Read it with
/// `context.fonts`.
@immutable
class ThemeFonts extends ThemeExtension<ThemeFonts> {
  /// Creates the font families.
  const new({
    this.sans,
    this.heading,
    this.mono = 'Menlo',
    this.monoFallback = const ['Consolas', 'monospace'],
  });

  /// The family of body text; `null` for the platform's.
  final String? sans;

  /// The family of headings; `null` for [sans].
  final String? heading;

  /// The family of code and figures.
  final String? mono;

  /// The families tried when [mono] is not installed.
  final List<String> monoFallback;

  /// The style of code and tabular figures: [mono] with its fallbacks.
  TextStyle monoStyle([TextStyle? base]) => (base ?? const TextStyle())
      .copyWith(fontFamily: mono, fontFamilyFallback: monoFallback);

  @override
  ThemeFonts copyWith({
    String? sans,
    String? heading,
    String? mono,
    List<String>? monoFallback,
  }) => ThemeFonts(
    sans: sans ?? this.sans,
    heading: heading ?? this.heading,
    mono: mono ?? this.mono,
    monoFallback: monoFallback ?? this.monoFallback,
  );

  /// Families do not blend: the switch happens halfway.
  @override
  ThemeFonts lerp(ThemeFonts? other, double t) =>
      other == null || t < 0.5 ? this : other;

  @override
  bool operator ==(Object other) =>
      other is ThemeFonts &&
      other.sans == sans &&
      other.heading == heading &&
      other.mono == mono &&
      other.monoFallback.join() == monoFallback.join();

  @override
  int get hashCode => Object.hash(sans, heading, mono, monoFallback.join());
}
