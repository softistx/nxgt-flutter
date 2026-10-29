# DateRangeField

Library: `package:nxgt_material/dates.dart`

A range of dates as a read-only field that opens Material's range picker, as a
`FormField<DateTimeRange>`.

## When to use it

A stay, a leave, a reporting period: two days in one field. The value is a
`DateTimeRange` whose start and end are `DateTime`s at midnight
(`DateUtils.dateOnly`). For one day use [DateField](date_field.md); for a bare
picker without form behaviour call Flutter's `showDateRangePicker`.

## Example

```dart
DateRangeField(
  label: 'Stay',
  required: true,
  firstDate: DateTime.now(),
  lastDate: DateTime.now().add(const Duration(days: 365)),
  onChanged: (range) => setState(() => _stay = range),
)
```

The text and the screen reader value read, for example, "Thu, May 14 to
Sat, May 16" ("du jeu. 14 mai au sam. 16 mai" in French): each date comes from
`MaterialLocalizations.formatMediumDate`, joined by this package's
`datesRangeValue` string. Add `GlobalMaterialLocalizations.delegate` to
`localizationsDelegates` for a language other than English (see
[Troubleshooting](../troubleshooting.md)). To word the whole range yourself:

```dart
DateRangeField(
  label: 'Stay',
  formatter: (r) => '${r.duration.inDays + 1} nights',
)
```

The picker is `showDateRangePicker` with its built-in toggle between the
calendar and typing the dates; `initialEntryMode: DatePickerEntryMode.input`
opens it on the typed entry. It opens on the field's range, each end moved into
`firstDate`..`lastDate`. A range whose start is before `firstDate` or whose end
is after `lastDate` is an error that names the bound ("Choose a date on or
after ..."). Inside a `Form`, `validate`, `save` and `reset` work as for any
field. The `validator` is only called with a range; an empty field is valid
unless `required`.

## Accessibility

One node reads as a button with the label and the spoken range as its value,
and the error (or the helper text) as its hint. Enter and Space on the focused
field open the picker; the picker is Material's own, with its keyboard and
screen reader support. The clear button is its own node, a 48 dp target named
"Clear <label>". The error under the field has the `alert` role; outside the
web it is also a live region. A disabled field ignores taps and is skipped by
validation.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The label, read by screen readers. |
| `initialValue` | `DateTimeRange?` | Starting range (ends taken at midnight), restored by `Form.reset`. |
| `firstDate` | `DateTime?` | Earliest date. Default 1 January 1900. |
| `lastDate` | `DateTime?` | Latest date. Default 31 December 2100. |
| `onChanged` | `ValueChanged<DateTimeRange?>?` | Called with the picked range, `null` when cleared. |
| `onSaved` | `FormFieldSetter<DateTimeRange>?` | Called by `FormState.save`. |
| `validator` | `FormFieldValidator<DateTimeRange>?` | Extra validator, after the required and range checks. |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the `Form`. |
| `enabled` | `bool` | Default `true`; a disabled field is not validated. |
| `required` | `bool` | Whether an empty field is an error. Default `false`. |
| `helperText` | `String?` | A hint under the field, replaced by the error. |
| `hintText` | `String?` | Placeholder of the empty field. |
| `initialEntryMode` | `DatePickerEntryMode` | Calendar (default) or typed input. |
| `formatter` | `String Function(DateTimeRange)?` | Words the whole range instead of "start to end". |
| `clearable` | `bool` | Shows a clear button once there is a range. Default `true`. |
| `focusNode` | `FocusNode?` | The focus node of the control. |
