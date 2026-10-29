import 'package:flutter/material.dart';
import 'package:nxgt_material/src/dates/date_bounds.dart';
import 'package:nxgt_material/src/dates/picker_field_base.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// A range of dates as a read-only field that opens Material's range picker.
///
/// The value is a [DateTimeRange] whose start and end are [DateTime]s at
/// midnight (`DateUtils.dateOnly`). The text reads "start to end" (in the
/// locale's words), each date through `MaterialLocalizations.formatMediumDate`
/// (the app needs `GlobalMaterialLocalizations.delegate` for a language other
/// than English), or [formatter] for the whole range. The picker is
/// `showDateRangePicker` with its built-in toggle between the calendar and
/// typing the dates. Works in a [Form] (validate, save, reset). For a bare
/// picker without form behaviour, call `showDateRangePicker`.
class DateRangeField extends StatelessWidget {
  /// Creates a DateRangeField.
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

  /// The range the field starts with, and returns to on `Form.reset`.
  final DateTimeRange? initialValue;

  /// The earliest date that can be picked. Defaults to 1 January 1900.
  final DateTime? firstDate;

  /// The latest date that can be picked. Defaults to 31 December 2100.
  final DateTime? lastDate;

  /// Called with the picked range, `null` when cleared.
  final ValueChanged<DateTimeRange?>? onChanged;

  /// Called by `FormState.save` with the range.
  final FormFieldSetter<DateTimeRange>? onSaved;

  /// An extra validator, run after the required and range checks. It is only
  /// called with a range: an empty field is valid unless [required].
  final FormFieldValidator<DateTimeRange>? validator;

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

  /// Words the whole range, instead of "start to end" in the locale's medium
  /// dates.
  final String Function(DateTimeRange range)? formatter;

  /// Whether the range can be cleared.
  final bool clearable;

  /// The focus node of the control.
  final FocusNode? focusNode;

  static DateTimeRange _normalize(DateTimeRange range) => DateTimeRange(
    start: DateUtils.dateOnly(range.start),
    end: DateUtils.dateOnly(range.end),
  );

  String _day(BuildContext context, DateTime date) =>
      MaterialLocalizations.of(context).formatMediumDate(date);

  String _format(BuildContext context, DateTimeRange range) {
    final custom = formatter;
    if (custom != null) return custom(range);
    return context.materialL10n.datesRangeValue(
      _day(context, range.start),
      _day(context, range.end),
    );
  }

  // A bound is worded by the field's formatter as a one-day range.
  String _bound(BuildContext context, DateTime date) => formatter == null
      ? _day(context, date)
      : formatter!(DateTimeRange(start: date, end: date));

  Future<DateTimeRange?> _pick(
    BuildContext context,
    DateTimeRange? current,
    DateBounds bounds,
  ) async {
    final start = current == null ? null : bounds.clamp(current.start);
    final end = current == null ? null : bounds.clamp(current.end);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: start == null || end == null
          ? null
          : DateTimeRange(start: start, end: end),
      firstDate: bounds.first,
      lastDate: bounds.last,
      helpText: label,
      initialEntryMode: initialEntryMode,
    );
    return picked == null ? null : _normalize(picked);
  }

  @override
  Widget build(BuildContext context) {
    final bounds = DateBounds(firstDate, lastDate);
    return PickerFieldBase<DateTimeRange>(
      label: label,
      icon: Icons.date_range_outlined,
      initialValue: initialValue == null ? null : _normalize(initialValue!),
      format: _format,
      pick: (context, current) => _pick(context, current, bounds),
      clearLabel: context.materialL10n.datesClear(label),
      rangeError: (context, range) => bounds.error(
        context.materialL10n,
        range.start,
        range.end,
        (day) => _bound(context, day),
      ),
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
