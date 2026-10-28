import 'package:flutter/material.dart';
import 'package:nxgt_material/actions.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: SplitButton, path: '[Actions]')
/// The default use-case of [SplitButton].
Widget buildSplitButtonDefault(BuildContext context) {
  return SplitButton(
    label: context.knobs.string(label: 'Label', initialValue: 'Save'),
    onPressed: () {},
    menuChildren: [
      MenuItemButton(onPressed: () {}, child: const Text('Save as draft')),
      MenuItemButton(onPressed: () {}, child: const Text('Save and close')),
    ],
  );
}
