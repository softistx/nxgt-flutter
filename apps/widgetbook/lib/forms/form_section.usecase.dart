import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/forms.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: FormSection, path: '[Forms]')
/// The default use-case of [FormSection].
Widget buildFormSectionDefault(BuildContext context) {
  return FormSection(
    title: context.knobs.string(label: 'Title', initialValue: 'Account'),
    description: context.knobs.stringOrNull(
      label: 'Description',
      initialValue: 'How you sign in.',
    ),
    children: const [
      EmailField(label: 'Email'),
      PasswordField(label: 'Password', newPassword: true, minLength: 8),
    ],
  );
}
