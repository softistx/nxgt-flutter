import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/theme.dart';

void main() {
  test('oklch red is sRGB red', () {
    final color = const Oklch(0.628, 0.2577, 29.23).toColor();

    expect((color.r * 255).round(), 255);
    expect((color.g * 255).round(), lessThan(3));
    expect((color.b * 255).round(), lessThan(3));
  });

  test('white and black round-trip', () {
    expect(
      const Oklch(1, 0, 0).toColor().toARGB32(),
      const Color(0xFFFFFFFF).toARGB32(),
    );
    expect(const Oklch(0, 0, 0).toColor().toARGB32(), 0xFF000000);
  });

  test('a colour reads back close to where it started', () {
    const color = Color(0xFF3F51B5);
    final back = Oklch.fromColor(color).toColor();

    expect((back.r - color.r).abs(), lessThan(0.01));
    expect((back.g - color.g).abs(), lessThan(0.01));
    expect((back.b - color.b).abs(), lessThan(0.01));
  });

  test('an out-of-gamut colour keeps its hue by losing chroma', () {
    final color = const Oklch(0.5, 0.4, 150).toColor();

    expect(Oklch.fromColor(color).h, closeTo(150, 3));
  });

  test('contrast ratio of black on white is 21', () {
    expect(
      wcagContrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
  });

  test('equality and copyWith', () {
    const a = Oklch(0.5, 0.1, 20);

    expect(a, const Oklch(0.5, 0.1, 20));
    expect(a.copyWith(l: 0.6), isNot(a));
    expect(a.hashCode, const Oklch(0.5, 0.1, 20).hashCode);
    expect(a.toString(), contains('Oklch'));
  });

  test('published sRGB to OKLCH values', () {
    final blue = Oklch.fromColor(const Color(0xFF0000FF));
    final green = Oklch.fromColor(const Color(0xFF00FF00));

    expect(blue.l, closeTo(0.452, 0.002));
    expect(blue.c, closeTo(0.313, 0.002));
    expect(blue.h, closeTo(264.05, 0.2));
    expect(green.l, closeTo(0.866, 0.002));
    expect(green.c, closeTo(0.295, 0.002));
    expect(green.h, closeTo(142.5, 0.2));
  });

  test('the gamut clamp holds at lightness 0 and 1', () {
    expect(const Oklch(0, 0.3, 40).toColor().toARGB32(), 0xFF000000);
    expect(const Oklch(1, 0.3, 40).toColor().toARGB32(), 0xFFFFFFFF);
  });
}
