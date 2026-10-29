import 'package:flutter/material.dart';
import 'package:nxgt_material/src/layout/window_size.dart';
import 'package:nxgt_material/src/selection/choice_field_base.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
import 'package:nxgt_material/src/selection/select_control.dart';

/// More options than this open a searchable sheet on a compact window.
const _sheetThreshold = 12;

/// A single choice in a list, as a form field that looks like a text field.
///
/// On Material 3 `DropdownMenu` (which is not a form field) for a few
/// options or from the medium window size up. On a compact window, with
/// [searchable] or more than 12 options, a tap opens a sheet
/// (`context.showAdaptiveSheet`) with a search box and a list of 48 dp tiles.
/// With `required` it is valid only once an option is chosen; without it a
/// clear button returns the value to `null`. Works in a [Form] (validate,
/// save, reset). For two to six options that should stay visible use
/// `RadioGroupField`.
///
/// The value is `T?`: `null` means nothing chosen.
class SelectField<T> extends ChoiceFieldBase<T?> {
  /// Creates a SelectField.
  const new({
    required super.label,
    required this.options,
    super.initialValue,
    super.focusNode,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.required,
    super.helperText,
    this.searchable = false,
    super.key,
  });

  /// The options, in display order. Values must be unique.
  final List<ChoiceOption<T>> options;

  /// Whether the user can type to filter the options.
  final bool searchable;

  @override
  Widget build(BuildContext context) {
    assertInOptions(options, initialValue, 'SelectField');
    final unique = uniqueOptions(options, 'SelectField');
    final sheet =
        context.windowSize == WindowSize.compact &&
        (searchable || unique.length > _sheetThreshold);
    return buildChoice(
      context,
      builder: (context, state) => SelectControl<T>(
        label: label,
        options: unique,
        value: state.value,
        enabled: enabled,
        required: this.required,
        searchable: searchable,
        sheet: sheet,
        focusNode: focusNode,
        hasError: enabled && state.hasError,
        onPick: (value) => change(state, value),
      ),
    );
  }
}
