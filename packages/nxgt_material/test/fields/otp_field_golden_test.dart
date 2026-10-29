import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';

Future<void> main() async {
  await goldenTest(
    'OtpField looks right in light and dark',
    fileName: 'otp_field',
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
              child: SizedBox(
                width: 360,
                child: Form(
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      const OtpField(label: 'Empty', helperText: 'Sent by SMS'),
                      OtpField(
                        label: 'Partial',
                        controller: TextEditingController(text: '123'),
                      ),
                      OtpField(
                        label: 'Error',
                        controller: TextEditingController(text: '12'),
                      ),
                      const OtpField(label: 'Disabled', enabled: false),
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
