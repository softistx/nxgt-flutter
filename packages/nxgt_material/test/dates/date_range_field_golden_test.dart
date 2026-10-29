import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/dates.dart';

Future<void> main() async {
  await goldenTest(
    'DateRangeField looks right in light and dark',
    fileName: 'date_range_field',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, field) in <(String, DateRangeField)>[
            ('empty', const DateRangeField(label: 'Stay')),
            (
              'filled',
              DateRangeField(
                label: 'Stay',
                initialValue: DateTimeRange(
                  start: DateTime(2026, 5, 14),
                  end: DateTime(2026, 5, 18),
                ),
              ),
            ),
            (
              'error',
              const DateRangeField(
                label: 'Stay',
                required: true,
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
            (
              'disabled',
              DateRangeField(
                label: 'Stay',
                initialValue: DateTimeRange(
                  start: DateTime(2026, 5, 14),
                  end: DateTime(2026, 5, 18),
                ),
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
