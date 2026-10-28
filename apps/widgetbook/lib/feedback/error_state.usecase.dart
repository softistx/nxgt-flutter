import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ErrorState, path: '[Feedback]')
/// The default use-case of [ErrorState].
Widget buildErrorStateDefault(BuildContext context) {
  return ErrorState(
    title: context.knobs.string(
      label: 'Title',
      initialValue: 'Something went wrong',
    ),
    message: context.knobs.string(
      label: 'Message',
      initialValue: 'An error occurred. Try again in a moment.',
    ),
    onRetry: context.knobs.boolean(label: 'Retry', initialValue: true)
        ? () => Future<void>.delayed(const Duration(seconds: 2))
        : null,
  );
}
