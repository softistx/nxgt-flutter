import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

List<ChoiceOption<String>> _options(BuildContext context) => [
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
];

@widgetbook.UseCase(
  name: 'Default',
  type: ChoiceChipsField,
  path: '[Selection]',
)
/// The default use-case of [ChoiceChipsField].
Widget buildChoiceChipsFieldDefault(BuildContext context) {
  return Form(
    child: ChoiceChipsField<String>(
      label: context.knobs.string(label: 'Label', initialValue: 'Plan'),
      options: _options(context),
      required: context.knobs.boolean(label: 'Required', initialValue: true),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      autovalidateMode: AutovalidateMode.always,
    ),
  );
}

@widgetbook.UseCase(
  name: 'Multiple',
  type: FilterChipsField,
  path: '[Selection]',
)
/// The multiple-choice use-case of [FilterChipsField].
Widget buildFilterChipsFieldMultiple(BuildContext context) {
  return Form(
    child: FilterChipsField<String>(
      label: context.knobs.string(label: 'Label', initialValue: 'Plans'),
      options: _options(context),
      required: context.knobs.boolean(label: 'Required', initialValue: true),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      autovalidateMode: AutovalidateMode.always,
    ),
  );
}
