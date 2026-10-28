import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

enum _Outcome { loading, data, empty, error }

@widgetbook.UseCase(name: 'Default', type: AsyncView, path: '[Feedback]')
/// The default use-case of [AsyncView].
Widget buildAsyncViewDefault(BuildContext context) {
  final outcome = context.knobs.object.dropdown(
    label: 'Outcome',
    options: _Outcome.values,
    labelBuilder: (o) => o.name,
  );
  return AsyncView<List<String>>(
    snapshot: switch (outcome) {
      _Outcome.loading => const AsyncSnapshot.waiting(),
      _Outcome.data => const AsyncSnapshot.withData(ConnectionState.done, [
        'Invoice 1',
        'Invoice 2',
      ]),
      _Outcome.empty => const AsyncSnapshot.withData(
        ConnectionState.done,
        <String>[],
      ),
      _Outcome.error => const AsyncSnapshot.withError(
        ConnectionState.done,
        'boom',
      ),
    },
    isEmpty: (items) => items.isEmpty,
    onRetry: () async {},
    builder: (context, items) => ListView(
      children: [for (final item in items) ListTile(title: Text(item))],
    ),
  );
}
