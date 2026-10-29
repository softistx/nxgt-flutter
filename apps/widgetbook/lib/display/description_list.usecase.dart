import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DescriptionList, path: '[Display]')
/// The default use-case of [DescriptionList].
Widget buildDescriptionListDefault(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: DescriptionList(
      items: [
        DescriptionItem(
          label: 'Invoice',
          value: context.knobs.string(
            label: 'Invoice',
            initialValue: 'INV-2026-0042',
          ),
          copyable: context.knobs.boolean(
            label: 'Invoice copyable',
            initialValue: true,
          ),
        ),
        const DescriptionItem(label: 'Customer', value: 'Ada Lovelace'),
        const DescriptionItem(label: 'Issued', value: '28 October 2026'),
      ],
    ),
  );
}
