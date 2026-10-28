import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/actions.dart';

Future<void> main() async {
  await goldenTest(
    'CopyButton looks right in light and dark',
    fileName: 'copy_button',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          GoldenTestScenario(
            name: brightness.name,
            child: Theme(
              data: ThemeData(
                colorSchemeSeed: Colors.indigo,
                brightness: brightness,
              ),
              child: const CopyButton(value: 'INV-2026-0042'),
            ),
          ),
      ],
    ),
  );
}
