import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'EmptyState looks right in light and dark',
    fileName: 'empty_state',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          GoldenTestScenario(
            name: brightness.name,
            child: Theme(
              data: brightness == Brightness.light
                  ? ThemePresets.ocean.light()
                  : ThemePresets.ocean.dark(),
              child: Material(
                child: SizedBox(
                  width: 320,
                  child: EmptyState(
                    action: FilledButton(
                      onPressed: () {},
                      child: const Text('New invoice'),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
