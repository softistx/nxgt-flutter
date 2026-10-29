import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: CheckboxGroupField,
  path: '[Selection]',
)
/// The default use-case of [CheckboxGroupField].
Widget buildCheckboxGroupFieldDefault(BuildContext context) {
  return Form(
    child: CheckboxGroupField<String>(
      label: context.knobs.string(label: 'Label', initialValue: 'Notify me by'),
      options: [
        const ChoiceOption(value: 'email', label: 'Email'),
        const ChoiceOption(
          value: 'sms',
          label: 'SMS',
          description: 'Rates may apply',
        ),
        ChoiceOption(
          value: 'push',
          label: 'Push',
          enabled: context.knobs.boolean(label: 'Push enabled'),
        ),
      ],
      required: context.knobs.boolean(label: 'Required', initialValue: true),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      autovalidateMode: AutovalidateMode.always,
    ),
  );
}
