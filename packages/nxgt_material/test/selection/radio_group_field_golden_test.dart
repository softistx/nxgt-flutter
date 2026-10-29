import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';

const List<ChoiceOption<String>> _options = [
  ChoiceOption(value: 'a', label: 'Monthly', description: 'Billed every month'),
  ChoiceOption(value: 'b', label: 'Yearly'),
  ChoiceOption(value: 'c', label: 'Lifetime', enabled: false),
];

Future<void> main() async {
  await goldenTest(
    'RadioGroupField looks right in light and dark',
    fileName: 'radio_group_field',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, field) in <(String, RadioGroupField<String>)>[
            (
              'default',
              const RadioGroupField(label: 'Plan', options: _options),
            ),
            (
              'selected',
              const RadioGroupField(
                label: 'Plan',
                options: _options,
                initialValue: 'a',
              ),
            ),
            (
              'error',
              const RadioGroupField(
                label: 'Plan',
                options: _options,
                required: true,
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
            (
              'disabled',
              const RadioGroupField(
                label: 'Plan',
                options: _options,
                initialValue: 'b',
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
