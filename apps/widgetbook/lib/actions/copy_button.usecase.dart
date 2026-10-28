import 'package:flutter/material.dart';
import 'package:nxgt_material/actions.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: CopyButton, path: '[Actions]')
/// The default use-case of [CopyButton].
Widget buildCopyButtonDefault(BuildContext context) {
  return CopyButton(
    value: context.knobs.string(label: 'Value', initialValue: 'INV-2026-0042'),
  );
}
