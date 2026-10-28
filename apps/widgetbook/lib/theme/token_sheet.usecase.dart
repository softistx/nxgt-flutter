import 'package:flutter/material.dart';
import 'package:nxgt_material/theme.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: TokenSheet, path: '[Theme]')
/// The tones and the radius scale of the theme chosen in the theme addon.
Widget buildTokenSheetDefault(BuildContext context) {
  return const SingleChildScrollView(child: TokenSheet());
}
