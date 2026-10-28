import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/forms.dart';

Future<void> main() async {
  await goldenTest(
    'FormSection looks right in light and dark',
    fileName: 'form_section',
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
                      FormSection(
                        title: 'Account',
                        description: 'How you sign in.',
                        children: [
                          EmailField(label: 'Email'),
                          PasswordField(label: 'Password'),
                        ],
                      ),
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
