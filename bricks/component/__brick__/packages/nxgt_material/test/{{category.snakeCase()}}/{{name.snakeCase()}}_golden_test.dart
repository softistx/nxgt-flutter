import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/src/{{category.snakeCase()}}/{{name.snakeCase()}}.dart';

Future<void> main() async {
  await goldenTest(
    '{{name.pascalCase()}} looks right in light and dark',
    fileName: '{{name.snakeCase()}}',
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
              child: const {{name.pascalCase()}}(label: 'Hello'),
            ),
          ),
      ],
    ),
  );
}
