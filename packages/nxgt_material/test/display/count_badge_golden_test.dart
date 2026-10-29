import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'CountBadge looks right for 0, 7 and 120, light and dark',
    fileName: 'count_badge',
    builder: () => GoldenTestGroup(
      columns: 3,
      children: [
        for (final brightness in Brightness.values)
          for (final count in const [0, 7, 120])
            GoldenTestScenario(
              name: '${brightness.name} $count',
              child: Theme(
                data: brightness == Brightness.light
                    ? ThemePresets.ocean.light()
                    : ThemePresets.ocean.dark(),
                child: Material(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CountBadge(
                      count: count,
                      child: const Icon(Icons.mail_outline),
                    ),
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}
