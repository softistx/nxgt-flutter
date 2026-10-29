# TimeField

Library: `package:nxgt_material/dates.dart`

A time of day as a read-only field that opens Material's time picker, as a
`FormField<TimeOfDay>`.

## When to use it

An opening hour, a reminder, an appointment slot: one time in a form, worded
for the user's clock. The value is a `TimeOfDay`. For a bare picker without
form behaviour call Flutter's `showTimePicker`.

## Example

```dart
TimeField(
  label: 'Start time',
  required: true,
  onChanged: (time) => setState(() => _start = time),
)
```

The text follows the locale through `MaterialLocalizations.formatTimeOfDay`;
add `GlobalMaterialLocalizations.delegate` to `localizationsDelegates` for a
language other than English (see [Troubleshooting](../troubleshooting.md)).
To word the time yourself:

```dart
TimeField(
  label: 'Opens',
  formatter: (t) => '${t.hour}h${t.minute.toString().padLeft(2, '0')}',
)
```

## 12 or 24 hour clock

`use24HourFormat: null` (the default) follows
`MediaQuery.alwaysUse24HourFormat`, which the platform sets from the user's
system setting, and the locale's own convention otherwise. Pass `true` or
`false` to force the clock in both the field text and the picker:

```dart
const TimeField(label: 'Departure', use24HourFormat: true) // 14:30
```

The picker is `showTimePicker` with its built-in toggle between the dial and
typing a time; `initialEntryMode: TimePickerEntryMode.input` opens it on the
typed entry. It opens on the field's value, or the current time. Inside a
`Form`, `validate`, `save` and `reset` work as for any field.

## Accessibility

One node reads as a button with the label and the formatted time as its
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
| `initialValue` | `TimeOfDay?` | Starting time, restored by `Form.reset`. |
| `onChanged` | `ValueChanged<TimeOfDay?>?` | Called with the picked time, `null` when cleared. |
| `onSaved` | `FormFieldSetter<TimeOfDay>?` | Called by `FormState.save`. |
| `validator` | `FormFieldValidator<TimeOfDay>?` | Extra validator, after the required check. |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the `Form`. |
| `enabled` | `bool` | Default `true`; a disabled field is not validated. |
| `required` | `bool` | Whether an empty field is an error. Default `false`. |
| `helperText` | `String?` | A hint under the field, replaced by the error. |
| `hintText` | `String?` | Placeholder of the empty field. |
| `initialEntryMode` | `TimePickerEntryMode` | Dial (default) or typed input. |
| `formatter` | `String Function(TimeOfDay)?` | Words the time instead of the locale's format. |
| `use24HourFormat` | `bool?` | Forces the 24 (`true`) or 12 (`false`) hour clock; `null` follows the platform. |
| `clearable` | `bool` | Shows a clear button once there is a time. Default `true`. |
| `focusNode` | `FocusNode?` | The focus node of the control. |
