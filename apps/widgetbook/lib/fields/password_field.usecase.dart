import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: PasswordField, path: '[Fields]')
/// The default use-case of [PasswordField].
Widget buildPasswordFieldDefault(BuildContext context) {
  return Form(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: PasswordField(
      label: context.knobs.string(label: 'Label', initialValue: 'Password'),
      required: context.knobs.boolean(label: 'Required'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      newPassword: context.knobs.boolean(label: 'New password'),
      minLength: context.knobs.intOrNull.input(label: 'Min length'),
    ),
  );
}
