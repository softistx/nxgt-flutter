import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: NumberField, path: '[Fields]')
/// The default use-case of [NumberField].
Widget buildNumberFieldDefault(BuildContext context) {
  return Form(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: NumberField(
      label: context.knobs.string(label: 'Label', initialValue: 'Quantity'),
      required: context.knobs.boolean(label: 'Required'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      allowDecimal: context.knobs.boolean(label: 'Allow decimal'),
      min: context.knobs.intOrNull.input(label: 'Min'),
      max: context.knobs.intOrNull.input(label: 'Max'),
    ),
  );
}
