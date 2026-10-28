import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: TextAreaField, path: '[Fields]')
/// The default use-case of [TextAreaField].
Widget buildTextAreaFieldDefault(BuildContext context) {
  return Form(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: TextAreaField(
      label: context.knobs.string(label: 'Label', initialValue: 'Notes'),
      required: context.knobs.boolean(label: 'Required'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
      maxLength: context.knobs.intOrNull.input(label: 'Max length'),
    ),
  );
}
