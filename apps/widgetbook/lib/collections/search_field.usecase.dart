import 'package:flutter/material.dart';
import 'package:nxgt_material/collections.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: SearchField, path: '[Collections]')
/// The default use-case of [SearchField].
Widget buildSearchFieldDefault(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SearchField(
      onChanged: (text) => debugPrint('search: "$text"'),
      onSubmitted: (text) => debugPrint('submit: "$text"'),
      debounce: Duration(
        milliseconds: context.knobs.int.slider(
          label: 'Debounce (ms)',
          initialValue: 300,
          max: 1000,
          divisions: 20,
        ),
      ),
      hintText: context.knobs.stringOrNull(label: 'Hint text'),
      enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
    ),
  );
}
