import 'package:flutter/material.dart';
import 'package:nxgt_material/src/dates/picker_field_base.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// A date as a read-only field that opens Material's date picker.
///
/// The value is a [DateTime] at midnight (`DateUtils.dateOnly`), so two
/// dates compare equal whatever the time of day. The text follows the
/// locale through `MaterialLocalizations.formatMediumDate` (the app needs
/// `GlobalMaterialLocalizations.delegate` for a language other than English),
/// or [formatter]. The picker is `showDatePicker` with its built-in toggle
/// between the calendar and typing a date. Works in a [Form] (validate, save,
/// reset). For a bare picker without form behaviour, call `showDatePicker`.
class DateField extends StatelessWidget {
  /// Creates a DateField.
  const new({
    required this.label,
    this.initialValue,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.required = false,
    this.helperText,
    this.hintText,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.formatter,
    this.clearable = true,
    this.focusNode,
    super.key,
  });

  /// The label, read by screen readers.
  final String label;

  /// The date the field starts with, and returns to on `Form.reset`.
  final DateTime? initialValue;

  /// The earliest date that can be picked. Defaults to 1 January 1900.
  final DateTime? firstDate;

  /// The latest date that can be picked. Defaults to 31 December 2100.
  final DateTime? lastDate;

  /// Called with the picked date, `null` when cleared.
  final ValueChanged<DateTime?>? onChanged;

  /// Called by `FormState.save` with the date.
  final FormFieldSetter<DateTime>? onSaved;

  /// An extra validator, run after the required and range checks. It is only
  /// called with a date: an empty field is valid unless [required].
  final FormFieldValidator<DateTime>? validator;

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

  /// How the picker opens: the calendar, or the typed input.
  final DatePickerEntryMode initialEntryMode;

  /// Words the date, instead of the locale's medium date.
  final String Function(DateTime date)? formatter;

  /// Whether the date can be cleared.
  final bool clearable;

  /// The focus node of the control.
  final FocusNode? focusNode;

  DateTime get _first => DateUtils.dateOnly(firstDate ?? DateTime(1900));

  DateTime get _last => DateUtils.dateOnly(lastDate ?? DateTime(2100, 12, 31));

  String _format(BuildContext context, DateTime date) =>
      formatter?.call(date) ??
      MaterialLocalizations.of(context).formatMediumDate(date);

  String? _range(BuildContext context, DateTime date) {
    final l10n = context.materialL10n;
    if (date.isBefore(_first)) {
      return l10n.datesBefore(_format(context, _first));
    }
    if (date.isAfter(_last)) return l10n.datesAfter(_format(context, _last));
    return null;
  }

  Future<DateTime?> _pick(BuildContext context, DateTime? current) async {
    final first = _first;
    final last = _last;
    var start = DateUtils.dateOnly(current ?? DateTime.now());
    if (start.isBefore(first)) start = first;
    if (start.isAfter(last)) start = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: first,
      lastDate: last,
      helpText: label,
      initialEntryMode: initialEntryMode,
    );
    return picked == null ? null : DateUtils.dateOnly(picked);
  }

  @override
  Widget build(BuildContext context) {
    return PickerFieldBase<DateTime>(
      label: label,
      icon: Icons.calendar_today_outlined,
      initialValue: initialValue == null
          ? null
          : DateUtils.dateOnly(initialValue!),
      format: _format,
      pick: _pick,
      clearLabel: context.materialL10n.datesClear(label),
      rangeError: _range,
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
