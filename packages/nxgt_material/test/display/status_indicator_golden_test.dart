import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'StatusIndicator looks right in every tone, light and dark',
    fileName: 'status_indicator',
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
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        StatusIndicator(label: tone.name, tone: tone),
                        StatusIndicator(
                          label: tone.name,
                          tone: tone,
                          dot: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}
