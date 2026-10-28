import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'LoadingState looks right in light and dark',
    fileName: 'loading_state',
    // The spinner never settles; one frame is the golden.
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          GoldenTestScenario(
            name: brightness.name,
            child: Theme(
              data: brightness == Brightness.light
                  ? ThemePresets.ocean.light()
                  : ThemePresets.ocean.dark(),
              child: const Material(
                child: SizedBox(width: 320, child: LoadingState()),
              ),
            ),
          ),
      ],
    ),
  );
}
