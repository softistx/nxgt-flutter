import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';

Future<void> main() async {
  await goldenTest(
    'SwitchField looks right in light and dark',
    fileName: 'switch_field',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, field) in <(String, SwitchField)>[
            ('off', const SwitchField(label: 'Notifications')),
            (
              'on',
              const SwitchField(label: 'Notifications', initialValue: true),
            ),
            (
              'error',
              SwitchField(
                label: 'Notifications',
                validator: (on) => on == true ? null : 'Turn this on',
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
            (
              'disabled',
              const SwitchField(label: 'Notifications', enabled: false),
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
