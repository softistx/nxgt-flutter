import 'package:flutter/material.dart';
import 'package:nxgt_material/actions.dart';
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/forms.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: SubmitButton, path: '[Forms]')
/// The default use-case of [SubmitButton].
Widget buildSubmitButtonDefault(BuildContext context) {
  return Form(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        const EmailField(label: 'Email', required: true),
        SubmitButton(
          label: context.knobs.string(label: 'Label', initialValue: 'Send'),
          variant: context.knobs.object.dropdown(
            label: 'Variant',
            options: AsyncButtonVariant.values,
            labelBuilder: (v) => v.name,
          ),
          onSubmit: () => Future<void>.delayed(const Duration(seconds: 2)),
        ),
      ],
    ),
  );
}
