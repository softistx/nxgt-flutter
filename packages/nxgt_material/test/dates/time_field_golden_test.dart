import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/dates.dart';

Future<void> main() async {
  await goldenTest(
    'TimeField looks right in light and dark',
    fileName: 'time_field',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, field) in <(String, TimeField)>[
            ('empty', const TimeField(label: 'Start time')),
            (
              'filled',
              const TimeField(
                label: 'Start time',
                initialValue: TimeOfDay(hour: 14, minute: 30),
              ),
            ),
            (
              'error',
              const TimeField(
                label: 'Start time',
                required: true,
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
            (
              'disabled',
              const TimeField(
                label: 'Start time',
                initialValue: TimeOfDay(hour: 14, minute: 30),
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
