import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  final spec = ThemePresets.ocean.copyWith(
    tones: {'maths': const ToneSeed(Oklch(0.5, 0.14, 300))},
  );
  await goldenTest(
    'TokenSheet shows the tones and the radius scale in light and dark',
    fileName: 'token_sheet',
    constraints: const BoxConstraints(maxWidth: 440),
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        for (final brightness in Brightness.values)
          GoldenTestScenario(
            name: brightness.name,
            child: Theme(
              data: spec.data(brightness),
              child: const TokenSheet(),
            ),
          ),
      ],
    ),
  );
}
