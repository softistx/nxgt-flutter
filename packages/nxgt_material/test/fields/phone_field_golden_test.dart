import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';

Future<void> main() async {
  await goldenTest(
    'PhoneField looks right in light and dark',
    fileName: 'phone_field',
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
                      PhoneField(label: 'Empty'),
                      PhoneField(
                        label: 'Filled',
                        initialValue: '+33 6 12 34 56 78',
                      ),
                      PhoneField(
                        label: 'Error',
                        initialValue: '12',
                        autovalidateMode: AutovalidateMode.always,
                      ),
                      PhoneField(label: 'Disabled', enabled: false),
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
