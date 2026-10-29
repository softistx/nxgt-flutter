import 'package:flutter/material.dart';
import 'package:nxgt_material/selection.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: SwitchField, path: '[Selection]')
/// The default use-case of [SwitchField].
Widget buildSwitchFieldDefault(BuildContext context) {
  return Form(
    child: SwitchField(
      label: context.knobs.string(
        label: 'Label',
        initialValue: 'Notifications',
      ),
      helperText: context.knobs.stringOrNull(
        label: 'Helper text',
        initialValue: 'Sent by email',
      ),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
    ),
  );
}
