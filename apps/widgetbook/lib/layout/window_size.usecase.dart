import 'package:flutter/material.dart';
import 'package:nxgt_material/layout.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: WindowSize, path: '[Layout]')
/// The default use-case of [WindowSize]: the class of the viewport.
Widget buildWindowSizeDefault(BuildContext context) {
  final size = context.windowSize;
  return Center(
    child: Text(
      '${size.name} (from ${size.minWidth.round()} dp)',
      style: Theme.of(context).textTheme.headlineMedium,
    ),
  );
}
