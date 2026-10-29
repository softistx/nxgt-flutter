import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';

const List<ChoiceOption<String>> _options = [
  ChoiceOption(value: 'fr', label: 'France'),
  ChoiceOption(value: 'ci', label: "Côte d'Ivoire", description: 'Afrique'),
  ChoiceOption(value: 'xx', label: 'Ailleurs', enabled: false),
];

Future<void> main() async {
  await goldenTest(
    'SelectField looks right in light and dark',
    fileName: 'select_field',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, field) in <(String, SelectField<String>)>[
            ('empty', const SelectField(label: 'Country', options: _options)),
            (
              'chosen',
              const SelectField(
                label: 'Country',
                options: _options,
                initialValue: 'ci',
                helperText: 'Where you live',
              ),
            ),
            (
              'error',
              const SelectField(
                label: 'Country',
                options: _options,
                required: true,
                autovalidateMode: AutovalidateMode.always,
              ),
            ),
            (
              'disabled',
              const SelectField(
                label: 'Country',
                options: _options,
                initialValue: 'fr',
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
