import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'InlineAlert looks right in every tone, light and dark',
    fileName: 'inline_alert',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final brightness in Brightness.values)
          for (final tone in FeedbackTone.values)
            GoldenTestScenario(
              name: '${brightness.name} ${tone.name}',
              child: Theme(
                data: brightness == Brightness.light
                    ? ThemePresets.ocean.light()
                    : ThemePresets.ocean.dark(),
                child: Material(
                  child: SizedBox(
                    width: 320,
                    child: InlineAlert(
                      tone: tone,
                      title: 'Heads up',
                      message: 'Something worth reading.',
                      onDismiss: () {},
                    ),
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}
