import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A colour in OKLCH: lightness 0 to 1, chroma, hue in degrees.
///
/// The seeds of `@nxgt/material` are written in OKLCH, so the presets are
/// ported with the same numbers. [toColor] reduces the chroma until the colour
/// fits sRGB, which keeps the hue instead of clipping it.
@immutable
class Oklch {
  /// Creates a colour from lightness [l], chroma [c] and hue [h] in degrees.
  const new(this.l, this.c, this.h);

  /// Reads the OKLCH value of an sRGB [color].
  factory fromColor(Color color) {
    final r = _toLinear(color.r);
    final g = _toLinear(color.g);
    final b = _toLinear(color.b);
    final l = _cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
    final m = _cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
    final s = _cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
    final lab = (
      0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
      1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
      0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
    );
    final chroma = math.sqrt(lab.$2 * lab.$2 + lab.$3 * lab.$3);
    final hue = chroma < 1e-4
        ? 0.0
        : (math.atan2(lab.$3, lab.$2) * 180 / math.pi + 360) % 360;
    return Oklch(lab.$1, chroma, hue);
  }

  /// Lightness, 0 (black) to 1 (white).
  final double l;

  /// Chroma, 0 for a grey, about 0.4 at most.
  final double c;

  /// Hue in degrees.
  final double h;

  /// This colour with the given parts replaced.
  Oklch copyWith({double? l, double? c, double? h}) =>
      Oklch(l ?? this.l, c ?? this.c, h ?? this.h);

  /// The sRGB colour, with the chroma lowered until it is inside the gamut.
  Color toColor() {
    final lightness = l.clamp(0.0, 1.0);
    final direct = _rgb(lightness, c, h);
    if (_inGamut(direct)) return _color(direct);
    var low = 0.0;
    var high = c;
    for (var i = 0; i < 24; i++) {
      final mid = (low + high) / 2;
      if (_inGamut(_rgb(lightness, mid, h))) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return _color(_rgb(lightness, low, h));
  }

  @override
  bool operator ==(Object other) =>
      other is Oklch && other.l == l && other.c == c && other.h == h;

  @override
  int get hashCode => Object.hash(l, c, h);

  @override
  String toString() => 'Oklch($l, $c, $h)';
}

double _cbrt(double x) =>
    x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();

double _toLinear(double v) =>
    v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

double _fromLinear(double v) => v <= 0.0031308
    ? v * 12.92
    : 1.055 * math.pow(v, 1 / 2.4).toDouble() - 0.055;

(double, double, double) _rgb(double lightness, double chroma, double hue) {
  final a = chroma * math.cos(hue * math.pi / 180);
  final b = chroma * math.sin(hue * math.pi / 180);
  final l = math.pow(lightness + 0.3963377774 * a + 0.2158037573 * b, 3);
  final m = math.pow(lightness - 0.1055613458 * a - 0.0638541728 * b, 3);
  final s = math.pow(lightness - 0.0894841775 * a - 1.2914855480 * b, 3);
  return (
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  );
}

bool _inGamut((double, double, double) rgb) {
  const eps = 1e-6;
  bool ok(double v) => v >= -eps && v <= 1 + eps;
  return ok(rgb.$1) && ok(rgb.$2) && ok(rgb.$3);
}

Color _color((double, double, double) rgb) => Color.from(
  alpha: 1,
  red: _fromLinear(rgb.$1.clamp(0.0, 1.0)),
  green: _fromLinear(rgb.$2.clamp(0.0, 1.0)),
  blue: _fromLinear(rgb.$3.clamp(0.0, 1.0)),
);
