import 'package:flutter/material.dart';

/// The field decoration of a field in error: the outline in the error colour.
InputDecorationThemeData selectErrorTheme(BuildContext context) {
  final color = Theme.of(context).colorScheme.error;
  OutlineInputBorder border(double width) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: width),
  );
  return InputDecorationThemeData(
    border: border(1),
    enabledBorder: border(1),
    focusedBorder: border(2),
    floatingLabelStyle: TextStyle(color: color),
  );
}
