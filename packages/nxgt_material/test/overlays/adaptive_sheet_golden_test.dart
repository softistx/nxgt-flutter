import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/overlays.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'AdaptiveSheet looks right, compact and medium, light and dark',
    fileName: 'adaptive_sheet',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final brightness in Brightness.values)
          for (final width in const [360.0, 400.0])
            GoldenTestScenario(
              name: '${brightness.name} ${width == 360 ? 'compact' : 'medium'}',
              constraints: BoxConstraints(maxWidth: width),
              child: Theme(
                data: brightness == Brightness.light
                    ? ThemePresets.ocean.light()
                    : ThemePresets.ocean.dark(),
                child: Builder(
                  builder: (context) => Material(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: const AdaptiveSheet(
                      title: 'Filters',
                      child: Text(
                        'Choose what the list shows. Your choice is kept '
                        'for the next visit.',
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
