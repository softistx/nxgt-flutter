import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';

Future<void> main() async {
  await goldenTest(
    'PasswordField looks right in light and dark',
    fileName: 'password_field',
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
                      PasswordField(label: 'Empty'),
                      PasswordField(label: 'Filled', initialValue: 'secret'),
                      PasswordField(
                        label: 'Error',
                        initialValue: 'abc',
                        minLength: 8,
                        autovalidateMode: AutovalidateMode.always,
                      ),
                      PasswordField(
                        label: 'Visible',
                        initialValue: 'secret',
                        initiallyVisible: true,
                      ),
                      PasswordField(label: 'Disabled', enabled: false),
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
