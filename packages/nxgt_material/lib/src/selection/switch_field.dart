import 'package:flutter/material.dart';
import 'package:nxgt_material/src/selection/choice_field_base.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// An on/off switch with its label, as a form field.
///
/// The "enable notifications" case: a full-width tile at least 48 dp high
/// whose whole row, label included, toggles the switch. It starts off unless
/// `initialValue` says otherwise. Works in a [Form] (validate, save, reset);
/// there is no `required`, since an off switch is a valid answer: add a
/// `validator` for a rule such as "must be on". For a switch inside a list of
/// settings without form behaviour, use Material's `SwitchListTile`.
class SwitchField extends ChoiceFieldBase<bool> {
  /// Creates a SwitchField.
  const new({
    required super.label,
    super.initialValue = false,
    super.focusNode,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.helperText,
    super.key,
  });

  @override
  bool isEmpty(bool value) => false;

  @override
  Widget build(BuildContext context) {
    return buildChoice(
      context,
      builder: (context, state) => ConstrainedBox(
        constraints: BoxConstraints(minHeight: minTarget.height),
        child: SwitchListTile(
          value: state.value ?? false,
          onChanged: enabled ? (value) => change(state, value) : null,
          focusNode: focusNode,
          title: Text(label),
          visualDensity: VisualDensity.standard,
        ),
      ),
    );
  }
}
