import 'package:flutter/material.dart';
import 'package:nxgt_material/src/dates/picker_field_base.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// A time of day as a read-only field that opens Material's time picker.
///
/// The value is a [TimeOfDay]. The text follows the locale through
/// `MaterialLocalizations.formatTimeOfDay` (the app needs
/// `GlobalMaterialLocalizations.delegate` for a language other than English),
/// or [formatter]. [use24HourFormat] forces the 12 or 24 hour clock in both
/// the text and the picker; `null` follows
/// `MediaQuery.alwaysUse24HourFormat`. The picker is `showTimePicker` with
/// its dial and typed-entry toggle. Works in a [Form] (validate, save,
/// reset). For a bare picker without form behaviour, call `showTimePicker`.
class TimeField extends StatelessWidget {
  /// Creates a TimeField.
  const new({
    required this.label,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.required = false,
    this.helperText,
    this.hintText,
    this.initialEntryMode = TimePickerEntryMode.dial,
    this.formatter,
    this.use24HourFormat,
    this.clearable = true,
    this.focusNode,
    super.key,
  });

  /// The label, read by screen readers.
  final String label;

  /// The time the field starts with, and returns to on `Form.reset`.
  final TimeOfDay? initialValue;

  /// Called with the picked time, `null` when cleared.
  final ValueChanged<TimeOfDay?>? onChanged;

  /// Called by `FormState.save` with the time.
  final FormFieldSetter<TimeOfDay>? onSaved;

  /// An extra validator, run after the required check. It is only called with
  /// a time: an empty field is valid unless [required].
  final FormFieldValidator<TimeOfDay>? validator;

  /// When to validate; `null` follows the enclosing [Form].
  final AutovalidateMode? autovalidateMode;

  /// Whether the field accepts input. A disabled field is never validated.
  final bool enabled;

  /// Whether an empty field is an error.
  final bool required;

  /// A hint under the field while there is no error.
  final String? helperText;

  /// A placeholder shown in the empty field.
  final String? hintText;

  /// How the picker opens: the dial, or the typed input.
  final TimePickerEntryMode initialEntryMode;

  /// Words the time, instead of the locale's time format.
  final String Function(TimeOfDay time)? formatter;

  /// Whether to use the 24 hour clock. `null` follows
  /// `MediaQuery.alwaysUse24HourFormat`.
  final bool? use24HourFormat;

  /// Whether the time can be cleared.
  final bool clearable;

  /// The focus node of the control.
  final FocusNode? focusNode;

  bool _is24(BuildContext context) =>
      use24HourFormat ?? MediaQuery.alwaysUse24HourFormatOf(context);

  String _format(BuildContext context, TimeOfDay time) =>
      formatter?.call(time) ??
      MaterialLocalizations.of(context)
          .formatTimeOfDay(time, alwaysUse24HourFormat: _is24(context));

  Future<TimeOfDay?> _pick(BuildContext context, TimeOfDay? current) {
    final force = use24HourFormat;
    return showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
      helpText: label,
      initialEntryMode: initialEntryMode,
      builder: force == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(alwaysUse24HourFormat: force),
              child: child!,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PickerFieldBase<TimeOfDay>(
      label: label,
      icon: Icons.schedule_outlined,
      initialValue: initialValue,
      format: _format,
      pick: _pick,
      clearLabel: context.materialL10n.datesClear(label),
      focusNode: focusNode,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      required: required,
      clearable: clearable,
      helperText: helperText,
      hintText: hintText,
    );
  }
}
