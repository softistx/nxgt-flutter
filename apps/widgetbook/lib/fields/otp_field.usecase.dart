import 'package:flutter/material.dart';
import 'package:nxgt_material/fields.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: OtpField, path: '[Fields]')
/// The default use-case of [OtpField].
Widget buildOtpFieldDefault(BuildContext context) {
  return Form(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: OtpField(
      label: context.knobs.string(
        label: 'Label',
        initialValue: 'Verification code',
      ),
      length: context.knobs.int.slider(
        label: 'Length',
        initialValue: 6,
        min: 3,
        max: 8,
      ),
      required: context.knobs.boolean(label: 'Required'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
      helperText: context.knobs.stringOrNull(label: 'Helper text'),
    ),
  );
}
