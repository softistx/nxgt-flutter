import 'package:flutter/material.dart';
import 'package:nxgt_material/dates.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: TimeField, path: '[Dates]')
/// The default use-case of [TimeField].
Widget buildTimeFieldDefault(BuildContext context) {
  return Form(
    child: TimeField(
      label: context.knobs.string(label: 'Label', initialValue: 'Start time'),
      required: context.knobs.boolean(label: 'Required'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      clearable: context.knobs.boolean(label: 'Clearable', initialValue: true),
      use24HourFormat: context.knobs.boolean(label: '24 hour clock'),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
    ),
  );
}
