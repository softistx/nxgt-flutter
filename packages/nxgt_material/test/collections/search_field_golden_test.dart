import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/collections.dart';

Future<void> main() async {
  await goldenTest(
    'SearchField looks right in light and dark',
    fileName: 'search_field',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, field) in <(String, SearchField)>[
            ('empty', SearchField(onChanged: (_) {})),
            (
              'with text',
              SearchField(onChanged: (_) {}, initialValue: 'amoxi'),
            ),
            ('disabled', SearchField(onChanged: (_) {}, enabled: false)),
          ])
            GoldenTestScenario(
              name: '${brightness.name} $name',
              child: SizedBox(
                width: 320,
                child: Theme(
                  data: ThemeData(
                    colorSchemeSeed: Colors.indigo,
                    brightness: brightness,
                  ),
                  child: field,
                ),
              ),
            ),
      ],
    ),
  );
}
