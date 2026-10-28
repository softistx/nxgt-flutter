import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// `context.showToast` is an extension, which cannot be a use-case `type`;
// the toast is a SnackBar, so it is filed under it.
@widgetbook.UseCase(name: 'showToast', type: SnackBar, path: '[Feedback]')
/// The default use-case of `context.showToast`.
Widget buildToastDefault(BuildContext context) {
  final tone = context.knobs.objectOrNull.dropdown<FeedbackTone>(
    label: 'Tone',
    options: FeedbackTone.values,
    labelBuilder: (t) => t.name,
  );
  final message = context.knobs.string(
    label: 'Message',
    initialValue: 'Changes saved',
  );
  return Center(
    child: Builder(
      builder: (context) => FilledButton(
        onPressed: () => context.showToast(
          message,
          tone: tone,
          actionLabel: 'Undo',
          onAction: () {},
        ),
        child: const Text('Show toast'),
      ),
    ),
  );
}
