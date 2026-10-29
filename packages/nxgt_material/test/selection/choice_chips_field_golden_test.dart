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
    'ChoiceChipsField and FilterChipsField look right in light and dark',
    fileName: 'choice_chips_field',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, field) in <(String, Widget)>[
            (
              'single',
              const ChoiceChipsField<String>(
                label: 'Plan',
                options: _options,
                initialValue: 'a',
              ),
            ),
            (
              'multiple',
              const FilterChipsField<String>(
                label: 'Plans',
                options: _options,
                initialValue: {'a', 'b'},
              ),
            ),
            (
              'error',
              const ChoiceChipsField<String>(
                label: 'Plan',
                options: _options,
                required: true,
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
            (
              'disabled',
              const FilterChipsField<String>(
                label: 'Plans',
                options: _options,
                initialValue: {'b'},
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
