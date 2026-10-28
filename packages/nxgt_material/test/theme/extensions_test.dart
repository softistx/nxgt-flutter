import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/theme.dart';

void main() {
  final light = ThemePresets.lavande.light().extension<Tones>()!;
  final dark = ThemePresets.lavande.dark().extension<Tones>()!;

  test('Tones.lerp is the start at 0 and the end at 1', () {
    expect(light.lerp(dark, 0).success, light.success);
    expect(light.lerp(dark, 1).success, dark.success);
    expect(light.lerp(null, 0.5), light);
  });

  test('Tones.lerp blends colours halfway', () {
    final mid = light.lerp(dark, 0.5).warning.color;

    expect(mid, Color.lerp(light.warning.color, dark.warning.color, 0.5));
  });

  test('Tones.lerp carries custom tones', () {
    final a = light.copyWith(
      custom: {'maths': light.info, 'only-a': light.info},
    );
    final b = dark.copyWith(custom: {'maths': dark.info, 'only-b': dark.info});
    final mid = a.lerp(b, 0.25);

    expect(
      mid['maths'].color,
      Color.lerp(light.info.color, dark.info.color, 0.25),
    );
    expect(mid['only-a'], light.info);
    expect(a.lerp(b, 0.75)['only-b'], dark.info);
  });

  test('Tones.copyWith replaces only what it is given', () {
    final changed = light.copyWith(success: light.error);

    expect(changed.success, light.error);
    expect(changed.info, light.info);
    expect(changed.copyWith(), changed);
  });

  test('an unknown tone throws', () {
    expect(() => light['nope'], throwsArgumentError);
  });

  test('the eight named tones come first, in order', () {
    expect(light.all.keys.toList(), [
      'primary',
      'secondary',
      'tertiary',
      'success',
      'info',
      'warning',
      'error',
      'neutral',
    ]);
  });

  test('ToneColors lerp, copyWith and equality', () {
    final a = light.success;
    final b = dark.success;

    expect(a.lerp(b, 0), a);
    expect(a.lerp(b, 1), b);
    expect(a.copyWith(color: b.color).color, b.color);
    expect(a.copyWith(), a);
    expect(a.hashCode, a.copyWith().hashCode);
    expect(a.pairs, hasLength(2));
  });

  test('RadiusScale lerp, copyWith and equality', () {
    const a = RadiusScale();
    const b = RadiusScale(base: 20, xl: 40);
    final mid = a.lerp(b, 0.5);

    expect(mid.base, 15);
    expect(mid.xl, 34);
    expect(a.lerp(null, 0.5), a);
    expect(a.copyWith(md: 14).md, 14);
    expect(a.copyWith(), a);
    expect(a.hashCode, const RadiusScale().hashCode);
    expect(const RadiusScale(item: 6).item, 6);
  });

  test('ThemeMotif and ThemeFonts switch halfway', () {
    const m1 = ThemeMotif.none;
    final m2 = m1.copyWith(preset: BackgroundPreset.waves, seed: 3);
    const f1 = ThemeFonts(sans: 'Inter');
    final f2 = f1.copyWith(sans: 'Roboto', heading: 'Fraunces');

    expect(m1.lerp(m2, 0.4), m1);
    expect(m1.lerp(m2, 0.6), m2);
    expect(m1.lerp(null, 1), m1);
    expect(m2.hashCode, isNot(m1.hashCode));
    expect(f1.lerp(f2, 0.4), f1);
    expect(f1.lerp(f2, 0.6), f2);
    expect(f1.lerp(null, 1), f1);
    expect(f2.hashCode, isNot(f1.hashCode));
    expect(f2.heading, 'Fraunces');
  });

  test('ThemeMotif.copyWith replaces every field', () {
    final motif = ThemeMotif.none.copyWith(
      preset: BackgroundPreset.shapes,
      tone: MotifTone.mixed,
      intensity: MotifIntensity.vivid,
      seed: 7,
      shapes: ['ring'],
      density: MotifDensity.high,
      size: MotifSize.large,
      rotate: true,
      fill: MotifFill.outline,
      moonPosition: const Offset(0.1, 0.2),
    );

    expect(motif.shapes, ['ring']);
    expect(motif.tone, MotifTone.mixed);
    expect(motif.moonPosition, const Offset(0.1, 0.2));
    expect(motif, isNot(ThemeMotif.none));
  });

  test('Tones.lerp with different custom keys keeps both sides', () {
    final a = light.copyWith(custom: {'a': light.info});
    final b = dark.copyWith(custom: {'b': dark.info});

    expect(a.lerp(b, 0.25).custom.keys.toSet(), {'a', 'b'});
    expect(a.lerp(b, 0.25)['a'], light.info);
    expect(a.lerp(b, 0.25)['b'], dark.info);
  });
}
