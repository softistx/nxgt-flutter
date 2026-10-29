import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';

Future<void> main() async {
  await goldenTest(
    'CheckboxField looks right in light and dark',
    fileName: 'checkbox_field',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, field) in <(String, CheckboxField)>[
            ('unchecked', const CheckboxField(label: 'Accept the terms')),
            (
              'checked',
              const CheckboxField(
                label: 'Accept the terms',
                initialValue: true,
              ),
            ),
            (
              'error',
              const CheckboxField(
                label: 'Accept the terms',
                required: true,
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
            (
              'disabled',
              const CheckboxField(label: 'Accept the terms', enabled: false),
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
