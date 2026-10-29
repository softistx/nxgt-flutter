import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: StatusIndicator, path: '[Display]')
/// The default use-case of [StatusIndicator].
Widget buildStatusIndicatorDefault(BuildContext context) {
  return StatusIndicator(
    label: context.knobs.string(label: 'Label', initialValue: 'Paid'),
    tone: context.knobs.object.dropdown(
      label: 'Tone',
      options: FeedbackTone.values,
      initialOption: FeedbackTone.success,
      labelBuilder: (tone) => tone.name,
    ),
    dot: context.knobs.boolean(label: 'Dot', initialValue: true),
  );
}
