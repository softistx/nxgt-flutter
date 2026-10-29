import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: SelectField, path: '[Selection]')
/// The default use-case of [SelectField].
Widget buildSelectFieldDefault(BuildContext context) {
  return Form(
    child: SelectField<String>(
      label: context.knobs.string(label: 'Label', initialValue: 'Country'),
      options: [
        const ChoiceOption(value: 'fr', label: 'France'),
        const ChoiceOption(
          value: 'ci',
          label: "Côte d'Ivoire",
          description: 'West Africa',
        ),
        const ChoiceOption(value: 'sn', label: 'Sénégal'),
        ChoiceOption(
          value: 'xx',
          label: 'Elsewhere',
          enabled: context.knobs.boolean(label: 'Elsewhere enabled'),
        ),
      ],
      searchable: context.knobs.boolean(label: 'Searchable'),
      required: context.knobs.boolean(label: 'Required'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      autovalidateMode: AutovalidateMode.always,
    ),
  );
}
