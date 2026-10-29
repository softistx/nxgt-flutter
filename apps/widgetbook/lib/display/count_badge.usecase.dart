import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: CountBadge, path: '[Display]')
/// The default use-case of [CountBadge].
Widget buildCountBadgeDefault(BuildContext context) {
  return Center(
    child: CountBadge(
      count: context.knobs.int.slider(
        label: 'Count',
        initialValue: 7,
        max: 150,
      ),
      max: context.knobs.int.slider(
        label: 'Max',
        initialValue: 99,
        min: 1,
        max: 150,
      ),
      semanticLabel: 'Inbox',
      child: const Icon(Icons.mail_outline, size: 32),
    ),
  );
}
