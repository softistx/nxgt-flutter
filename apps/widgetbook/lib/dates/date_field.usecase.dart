import 'package:flutter/material.dart';
import 'package:nxgt_material/dates.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DateField, path: '[Dates]')
/// The default use-case of [DateField].
Widget buildDateFieldDefault(BuildContext context) {
  return Form(
    child: DateField(
      label: context.knobs.string(label: 'Label', initialValue: 'Birth date'),
      required: context.knobs.boolean(label: 'Required'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      clearable: context.knobs.boolean(label: 'Clearable', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
    ),
  );
}
