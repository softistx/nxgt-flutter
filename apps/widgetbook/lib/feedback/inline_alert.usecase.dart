import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: InlineAlert, path: '[Feedback]')
/// The default use-case of [InlineAlert].
Widget buildInlineAlertDefault(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: InlineAlert(
      tone: context.knobs.object.dropdown(
        label: 'Tone',
        options: FeedbackTone.values,
        labelBuilder: (t) => t.name,
      ),
      title: context.knobs.string(label: 'Title', initialValue: 'Heads up'),
      message: context.knobs.string(
        label: 'Message',
        initialValue: 'Something worth reading.',
      ),
      onDismiss: context.knobs.boolean(label: 'Dismissible') ? () {} : null,
    ),
  );
}
