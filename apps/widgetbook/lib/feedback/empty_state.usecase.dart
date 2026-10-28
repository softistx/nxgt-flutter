import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: EmptyState, path: '[Feedback]')
/// The default use-case of [EmptyState].
Widget buildEmptyStateDefault(BuildContext context) {
  return EmptyState(
    title: context.knobs.string(label: 'Title', initialValue: 'No invoices'),
    message: context.knobs.string(
      label: 'Message',
      initialValue: 'Create the first one.',
    ),
    action: context.knobs.boolean(label: 'Action', initialValue: true)
        ? FilledButton(onPressed: () {}, child: const Text('New invoice'))
        : null,
  );
}
