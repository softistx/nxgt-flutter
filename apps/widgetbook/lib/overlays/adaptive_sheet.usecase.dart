import 'package:flutter/material.dart';
import 'package:nxgt_material/overlays.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AdaptiveSheet, path: '[Overlays]')
/// The default use-case of [AdaptiveSheet]: a button that opens it.
Widget buildAdaptiveSheetDefault(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: 'Filters');
  final lines = context.knobs.int.slider(
    label: 'Lines of content',
    initialValue: 3,
    min: 1,
    max: 60,
  );
  return Center(
    child: FilledButton(
      onPressed: () async {
        final applied = await context.showAdaptiveSheet<bool>(
          title: title,
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 1; i <= lines; i++) Text('Option $i'),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Search')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Apply'),
              ),
            ],
          ),
        );
        if (context.mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text(applied == true ? 'Applied' : 'Closed')),
          );
        }
      },
      child: const Text('Open the sheet'),
    ),
  );
}
