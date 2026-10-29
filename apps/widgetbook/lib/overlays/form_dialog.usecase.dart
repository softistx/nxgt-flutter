import 'package:flutter/material.dart';
import 'package:nxgt_material/overlays.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: FormDialog, path: '[Overlays]')
/// The default use-case of [FormDialog]: a button that opens it.
Widget buildFormDialogDefault(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'New invoice',
  );
  final fails = context.knobs.boolean(label: 'Submit fails');
  return Center(
    child: FilledButton(
      onPressed: () async {
        final name = await context.showFormDialog<String>(
          title: title,
          submitLabel: 'Create',
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Customer',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value ?? '').isEmpty ? 'Enter a customer' : null,
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          onSubmit: () async {
            await Future<void>.delayed(const Duration(seconds: 1));
            if (fails) throw StateError('The server refused the invoice.');
            return 'ACME';
          },
        );
        if (context.mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text(name == null ? 'Closed' : 'Created $name')),
          );
        }
      },
      child: const Text('Open the form'),
    ),
  );
}
