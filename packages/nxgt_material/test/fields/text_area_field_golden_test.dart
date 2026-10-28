import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';

Future<void> main() async {
  await goldenTest(
    'TextAreaField looks right in light and dark',
    fileName: 'text_area_field',
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
                      TextAreaField(label: 'Empty'),
                      TextAreaField(
                        label: 'Filled',
                        initialValue: 'Some notes\nover two lines',
                      ),
                      TextAreaField(
                        label: 'Error',
                        required: true,
                        autovalidateMode: AutovalidateMode.always,
                      ),
                      TextAreaField(
                        label: 'Counter',
                        initialValue: 'abc',
                        maxLength: 20,
                      ),
                      TextAreaField(label: 'Disabled', enabled: false),
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
