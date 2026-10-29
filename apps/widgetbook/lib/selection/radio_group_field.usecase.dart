import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: RadioGroupField, path: '[Selection]')
/// The default use-case of [RadioGroupField].
Widget buildRadioGroupFieldDefault(BuildContext context) {
  return Form(
    child: RadioGroupField<String>(
      label: context.knobs.string(label: 'Label', initialValue: 'Plan'),
      options: [
        const ChoiceOption(
          value: 'monthly',
          label: 'Monthly',
          description: 'Billed every month',
        ),
        const ChoiceOption(value: 'yearly', label: 'Yearly'),
        ChoiceOption(
          value: 'lifetime',
          label: 'Lifetime',
          enabled: context.knobs.boolean(label: 'Lifetime enabled'),
        ),
      ],
      required: context.knobs.boolean(label: 'Required', initialValue: true),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      autovalidateMode: AutovalidateMode.always,
    ),
  );
}
