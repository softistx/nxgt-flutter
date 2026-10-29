import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/dates.dart';

Future<void> main() async {
  await goldenTest(
    'DateField looks right in light and dark',
    fileName: 'date_field',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, field) in <(String, DateField)>[
            ('empty', const DateField(label: 'Birth date')),
            (
              'filled',
              DateField(
                label: 'Birth date',
                initialValue: DateTime(2026, 5, 14),
              ),
            ),
            (
              'error',
              const DateField(
                label: 'Birth date',
                required: true,
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
            (
              'disabled',
              DateField(
                label: 'Birth date',
                initialValue: DateTime(2026, 5, 14),
                enabled: false,
              ),
            ),
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
                  child: Form(child: field),
                ),
              ),
            ),
      ],
    ),
  );
}
