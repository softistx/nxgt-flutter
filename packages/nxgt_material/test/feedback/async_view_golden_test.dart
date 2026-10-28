import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'AsyncView looks right in light and dark',
    fileName: 'async_view',
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
                  child: AsyncView<List<String>>(
                    snapshot: const AsyncSnapshot.withData(
                      ConnectionState.done,
                      <String>[],
                    ),
                    isEmpty: (items) => items.isEmpty,
                    builder: (context, items) => const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
