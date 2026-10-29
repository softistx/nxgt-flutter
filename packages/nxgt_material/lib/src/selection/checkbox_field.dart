import 'package:flutter/material.dart';
import 'package:nxgt_material/src/selection/choice_field_base.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// A single checkbox with its label, as a form field.
///
/// The "accept the terms" case: a full-width tile at least 48 dp high whose
/// whole row, label included, toggles the box. With `required` it is valid
/// only once checked, and says so in the user's language. Works in a [Form]
/// (validate, save, reset). For a box inside a list of options, or without
/// form behaviour, use Material's `CheckboxListTile`.
class CheckboxField extends ChoiceFieldBase<bool> {
  /// Creates a CheckboxField.
  const new({
    required super.label,
    super.initialValue = false,
    super.focusNode,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.required,
    super.helperText,
    super.key,
  });

  @override
  bool isEmpty(bool value) => !value;

  @override
  Widget build(BuildContext context) {
    return buildChoice(
      context,
      builder: (context, state) => ConstrainedBox(
        constraints: BoxConstraints(minHeight: minTarget.height),
        child: CheckboxListTile(
          value: state.value ?? false,
          onChanged: enabled ? (value) => change(state, value ?? false) : null,
          focusNode: focusNode,
          title: Text(label),
          controlAffinity: ListTileControlAffinity.leading,
          visualDensity: VisualDensity.standard,
          isError: state.hasError && enabled,
        ),
      ),
    );
  }
}
