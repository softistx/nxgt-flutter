import 'package:flutter/material.dart';
import 'package:nxgt_material/layout.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: PageBody, path: '[Layout]')
/// The default use-case of [PageBody].
Widget buildPageBodyDefault(BuildContext context) {
  return PageBody(
    maxWidth: context.knobs.double.slider(
      label: 'Max width',
      initialValue: 800,
      min: 320,
      max: 1600,
    ),
    child: const ColoredBox(
      color: Colors.black12,
      child: SizedBox(height: 200, width: double.infinity),
    ),
  );
}
