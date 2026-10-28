import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/theme.dart';

void main() {
  test('the 14 presets of @nxgt/material, the default first', () {
    expect(ThemePresets.all.map((p) => p.name).toList(), [
      'lavande',
      'ocean',
      'foret',
      'ambre',
      'ardoise',
      'corail',
      'menthe',
      'prune',
      'sable',
      'slate',
      'pink',
      'bleumono',
      'bluemoon',
      'teal',
    ]);
    expect(ThemePresets.defaultPreset, ThemePresets.lavande);
  });

  test('every preset name is a valid id and unique', () {
    final names = ThemePresets.all.map((p) => p.name).toList();

    expect(names.toSet(), hasLength(names.length));
    for (final name in names) {
      expect(RegExp(r'^[a-z][a-z0-9-]*$').hasMatch(name), isTrue, reason: name);
    }
  });

  test('byName finds a preset or returns null', () {
    expect(ThemePresets.byName('ocean'), ThemePresets.ocean);
    expect(ThemePresets.byName('nope'), isNull);
  });

  test('presets keep the radius of @nxgt/material (rem x 16)', () {
    expect(ThemePresets.lavande.radius.base, 10);
    expect(ThemePresets.ocean.radius.base, 12);
    expect(ThemePresets.slate.radius.base, 4);
    expect(ThemePresets.pink.radius.base, 20);
    expect(ThemePresets.pink.radius.item, 20);
  });

  test('the radius scale is Material 3 Expressive', () {
    expect(const RadiusScale().steps.values.toList(), [
      4,
      8,
      12,
      16,
      20,
      28,
      32,
      48,
    ]);
  });

  test('presets keep their motif, fonts and mode', () {
    expect(ThemePresets.ocean.motif.preset, BackgroundPreset.waves);
    expect(ThemePresets.pink.motif.shapes, contains('m3-flower'));
    expect(ThemePresets.bluemoon.suggestedMode, ThemeMode.dark);
    expect(ThemePresets.bluemoon.motif.moonPosition, const Offset(0.8, 0.34));
    expect(ThemePresets.corail.fonts.sans, 'SF Pro Rounded');
    expect(ThemePresets.foret.fonts.sans, isNull);
    expect(BackgroundPreset.values, hasLength(50));
    expect(BackgroundPreset.lowPoly.id, 'low-poly');
  });

  test('every preset builds a light and a dark Material 3 theme', () {
    for (final preset in ThemePresets.all) {
      for (final theme in [preset.light(), preset.dark()]) {
        expect(theme.useMaterial3, isTrue, reason: preset.name);
        expect(theme.extension<Tones>(), isNotNull);
        expect(theme.extension<RadiusScale>(), preset.radius);
        expect(theme.extension<ThemeFonts>(), preset.fonts);
        expect(theme.extension<ThemeMotif>(), preset.motif);
      }
      expect(preset.light().brightness, Brightness.light);
      expect(preset.dark().brightness, Brightness.dark);
    }
  });

  test('secondary and tertiary seeds reach the colour scheme', () {
    final theme = ThemePresets.ocean.light();
    final tones = theme.extension<Tones>()!;

    expect(theme.colorScheme.secondary, tones.secondary.color);
    expect(theme.colorScheme.onTertiaryContainer, tones.tertiary.onContainer);
  });

  test('a preset is extended with copyWith, adding an app tone', () {
    final school = ThemePresets.ocean.copyWith(
      name: 'school',
      label: 'School',
      tones: {'maths': const ToneSeed(Oklch(0.5, 0.14, 300))},
    );
    final tones = school.light().extension<Tones>()!;

    expect(school.displayName, 'School');
    expect(ThemePresets.ocean.displayName, 'Océan');
    expect(tones['maths'], tones.custom['maths']);
    expect(tones.all.keys.last, 'maths');
    expect(school, isNot(ThemePresets.ocean));
    expect(school.hashCode, isNot(ThemePresets.ocean.hashCode));
  });

  test('teal moves success to hue 145', () {
    final teal = ThemePresets.teal.light().extension<Tones>()!;
    final lavande = ThemePresets.lavande.light().extension<Tones>()!;

    expect(teal.success.color, isNot(lavande.success.color));
  });

  test('a reserved or badly named tone is refused', () {
    final reserved = ThemePresets.ocean.copyWith(
      tones: {'strong': const ToneSeed(Oklch(0.5, 0.1, 10))},
    );
    final badName = ThemePresets.ocean.copyWith(name: 'Bad Name');

    expect(reserved.light, throwsAssertionError);
    expect(badName.light, throwsAssertionError);
  });

  test('a heading family reaches the headline styles', () {
    final spec = ThemePresets.ocean.copyWith(
      fonts: const ThemeFonts(sans: 'Inter', heading: 'Fraunces'),
    );

    expect(spec.light().textTheme.headlineSmall?.fontFamily, 'Fraunces');
    expect(spec.light().textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(spec.fonts.monoStyle().fontFamily, 'Menlo');
  });
}
