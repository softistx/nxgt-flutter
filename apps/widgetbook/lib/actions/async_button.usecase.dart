import 'package:flutter/material.dart';
import 'package:nxgt_material/actions.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AsyncButton, path: '[Actions]')
/// The default use-case of [AsyncButton].
Widget buildAsyncButtonDefault(BuildContext context) {
  return AsyncButton(
    label: context.knobs.string(label: 'Label', initialValue: 'Save'),
    variant: context.knobs.object.dropdown(
      label: 'Variant',
      options: AsyncButtonVariant.values,
      labelBuilder: (v) => v.name,
    ),
    loading: context.knobs.boolean(label: 'Loading'),
    onPressed: () => Future<void>.delayed(const Duration(seconds: 2)),
  );
}
