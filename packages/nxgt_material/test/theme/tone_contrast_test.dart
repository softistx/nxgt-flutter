import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/theme.dart';

/// WCAG AA text contrast.
const _aa = 4.5;

void main() {
  final withAppTones = ThemePresets.ocean.copyWith(
    name: 'school',
    tones: {
      'maths': const ToneSeed(Oklch(0.5, 0.14, 300)),
      'pale': const ToneSeed(Oklch(0.95, 0.05, 100)),
      'dusk': const ToneSeed(Oklch(0.3, 0.1, 20), dark: Oklch(0.8, 0.1, 20)),
    },
  );

  for (final spec in [...ThemePresets.all, withAppTones]) {
    for (final brightness in Brightness.values) {
      test('${spec.name} ${brightness.name}: every tone pair is AA', () {
        final tones = spec.data(brightness).extension<Tones>()!;

        for (final MapEntry(key: name, value: tone) in tones.all.entries) {
          final labels = ['$name on color', '$name on container'];
          for (final (i, (fg, bg)) in tone.pairs.indexed) {
            expect(
              contrastRatio(fg, bg),
              greaterThanOrEqualTo(_aa),
              reason: '${spec.name} ${brightness.name} ${labels[i]}',
            );
          }
        }
      });
    }
  }
}
