import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';

Future<void> main() async {
  await goldenTest(
    'NumberField looks right in light and dark',
    fileName: 'number_field',
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
              child: const SizedBox(
                width: 320,
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      NumberField(label: 'Empty'),
                      NumberField(label: 'Filled', initialValue: '42'),
                      NumberField(
                        label: 'Error',
                        initialValue: '120',
                        max: 99,
                        autovalidateMode: AutovalidateMode.always,
                      ),
                      NumberField(label: 'Disabled', enabled: false),
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
