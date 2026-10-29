import 'package:flutter/material.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// The menu entries of [options], 48 dp high, with the description as a
/// second line.
List<DropdownMenuEntry<T>> selectEntries<T>(
  List<ChoiceOption<T>> options,
  ThemeData theme,
) => [
  for (final option in options)
    DropdownMenuEntry<T>(
      value: option.value,
      label: option.label,
      enabled: option.enabled,
      style: targetStyle,
      labelWidget: option.description == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(option.label),
                Text(option.description!, style: theme.textTheme.bodySmall),
              ],
            ),
    ),
];

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
