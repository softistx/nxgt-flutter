import 'package:flutter/material.dart';
import 'package:nxgt_material/overlays.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ConfirmDialog, path: '[Overlays]')
/// The default use-case of [ConfirmDialog]: a button that opens it.
Widget buildConfirmDialogDefault(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Delete invoice?',
  );
  final message = context.knobs.string(
    label: 'Message',
    initialValue: 'The invoice and its payments are removed.',
  );
  final destructive = context.knobs.boolean(label: 'Destructive');
  final slow = context.knobs.boolean(label: 'Slow action (2 s)');
  return Center(
    child: FilledButton(
      onPressed: () async {
        final confirmed = await context.confirm(
          title: title,
          message: message,
          destructive: destructive,
          onConfirm: slow
              ? () => Future<void>.delayed(const Duration(seconds: 2))
              : null,
        );
        if (context.mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text(confirmed ? 'Confirmed' : 'Cancelled')),
          );
        }
      },
      child: const Text('Open the dialog'),
    ),
  );
}
