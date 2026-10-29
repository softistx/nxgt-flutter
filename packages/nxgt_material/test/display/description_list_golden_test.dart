import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/theme.dart';

const _items = [
  DescriptionItem(label: 'Invoice', value: 'INV-2026-0042', copyable: true),
  DescriptionItem(label: 'Customer', value: 'Ada Lovelace'),
  DescriptionItem(label: 'Issued', value: '28 October 2026'),
];

Future<void> main() async {
  await goldenTest(
    'DescriptionList looks right compact and medium, light and dark',
    fileName: 'description_list',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final brightness in Brightness.values)
          for (final (name, width) in const [
            ('compact', 360.0),
            ('medium', 640.0),
          ])
            GoldenTestScenario(
              name: '${brightness.name} $name',
              constraints: BoxConstraints(maxWidth: width),
              child: Theme(
                data: brightness == Brightness.light
                    ? ThemePresets.ocean.light()
                    : ThemePresets.ocean.dark(),
                child: Material(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: MediaQuery(
                      data: MediaQueryData(size: Size(width, 400)),
                      child: const DescriptionList(items: _items),
                    ),
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}
