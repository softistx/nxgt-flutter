import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
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

/// The trailing icons of a select: the clear button when [canClear], then the
/// arrow, up when [open].
Widget selectTrailing(
  BuildContext context, {
  required bool open,
  required bool canClear,
  required VoidCallback onClear,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (canClear)
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: context.materialL10n.selectionClear,
          onPressed: onClear,
          style: targetStyle,
        ),
      Icon(open ? Icons.arrow_drop_up : Icons.arrow_drop_down),
      const SizedBox(width: 8),
    ],
  );
}
