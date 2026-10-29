import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: CheckboxField, path: '[Selection]')
/// The default use-case of [CheckboxField].
Widget buildCheckboxFieldDefault(BuildContext context) {
  return Form(
    child: CheckboxField(
      label: context.knobs.string(
        label: 'Label',
        initialValue: 'I accept the terms of service',
      ),
      required: context.knobs.boolean(label: 'Required', initialValue: true),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      initialValue: context.knobs.boolean(label: 'Checked'),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      autovalidateMode: AutovalidateMode.always,
    ),
  );
}
