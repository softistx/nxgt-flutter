# DateField

Library: `package:nxgt_material/dates.dart`

A date as a read-only field that opens Material's date picker, as a
`FormField<DateTime>`.

## When to use it

A birth date, a due date, a start date: one day in a form, worded in the
user's language. The value is a `DateTime` at midnight
(`DateUtils.dateOnly`), so two dates compare equal whatever the time of day.
For a bare picker without form behaviour call Flutter's `showDatePicker`.

## Example

```dart
DateField(
  label: 'Birth date',
  required: true,
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
  onChanged: (date) => setState(() => _birth = date),
)
```

The text follows the locale through
`MaterialLocalizations.formatMediumDate`; add `GlobalMaterialLocalizations.delegate`
to `localizationsDelegates` for a language other than English (see
[Troubleshooting](../troubleshooting.md)). To word the date yourself:

```dart
DateField(
  label: 'Due',
  formatter: (d) => '${d.day}/${d.month}/${d.year}',
)
```

The picker is `showDatePicker` with its built-in toggle between the calendar
and typing a date; `initialEntryMode: DatePickerEntryMode.input` opens it on
the typed entry. The date it opens on is the field's value, or today, moved
into `firstDate`..`lastDate`. A value outside the range is an error that names
the bound ("Choose a date on or after ..."). Inside a `Form`, `validate`,
`save` and `reset` work as for any field.

## Accessibility

One node reads as a button with the label and the formatted date as its
value, and the error (or the helper text) as its hint. Enter and Space on the
focused field open the picker; the picker is Material's own, with its
keyboard and screen reader support. The clear button is its own node, a 48 dp
target named "Clear <label>". The error under the field has the `alert` role;
outside the web it is also a live region. A disabled field ignores taps and is
skipped by validation.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The label, read by screen readers. |
| `initialValue` | `DateTime?` | Starting date (taken at midnight), restored by `Form.reset`. |
| `firstDate` | `DateTime?` | Earliest date. Default 1 January 1900. |
| `lastDate` | `DateTime?` | Latest date. Default 31 December 2100. |
| `onChanged` | `ValueChanged<DateTime?>?` | Called with the picked date, `null` when cleared. |
| `onSaved` | `FormFieldSetter<DateTime>?` | Called by `FormState.save`. |
| `validator` | `FormFieldValidator<DateTime>?` | Extra validator, after the required and range checks. |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the `Form`. |
| `enabled` | `bool` | Default `true`; a disabled field is not validated. |
| `required` | `bool` | Whether an empty field is an error. Default `false`. |
| `helperText` | `String?` | A hint under the field, replaced by the error. |
| `hintText` | `String?` | Placeholder of the empty field. |
| `initialEntryMode` | `DatePickerEntryMode` | Calendar (default) or typed input. |
| `formatter` | `String Function(DateTime)?` | Words the date instead of the locale's medium date. |
| `clearable` | `bool` | Shows a clear button once there is a date. Default `true`. |
| `focusNode` | `FocusNode?` | The focus node of the control. |
