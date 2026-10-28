import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: LoadingState, path: '[Feedback]')
/// The default use-case of [LoadingState].
Widget buildLoadingStateDefault(BuildContext context) {
  return LoadingState(
    message: context.knobs.string(label: 'Message', initialValue: 'Loading'),
  );
}
