import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';

Future<void> main() async {
  await goldenTest(
    'EmailField looks right in light and dark',
    fileName: 'email_field',
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
                      EmailField(label: 'Empty'),
                      EmailField(
                        label: 'Filled',
                        initialValue: 'ada@example.com',
                      ),
                      EmailField(
                        label: 'Error',
                        initialValue: 'nope',
                        autovalidateMode: AutovalidateMode.always,
                      ),
                      EmailField(label: 'Disabled', enabled: false),
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
