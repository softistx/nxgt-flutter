# Dates

`package:nxgt_material/dates.dart` holds the fields that pick a date or a
time, `DateField`, `DateRangeField` and `TimeField`: each a `FormField` that shows its value as
read-only text, opens Material's picker on tap, Enter or Space, and follows
the app's locale.

## Setup

The text and the picker come from Flutter's `MaterialLocalizations`, so the
app needs `GlobalMaterialLocalizations.delegate` and the languages it
supports. Without it a French app shows English dates and times (see
[Troubleshooting](../troubleshooting.md)).

## DateField

```dart
Form(
  key: _form,
  child: DateField(
    label: 'Appointment',
    required: true,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 90)),
    onSaved: (date) => _appointment = date,
  ),
)
```

- The value is a `DateTime` at midnight (`DateUtils.dateOnly`): compare dates
  with `==` or `isAtSameMomentAs`, not by time of day.
- The default text is `MaterialLocalizations.formatMediumDate`; pass
  `formatter` to word it differently.
- The picker opens on the current value, or today, moved into the allowed
  range. A value outside `firstDate`..`lastDate` fails validation and the
  error names the bound.
- The picker offers its built-in toggle between the calendar and typing a date.

See [DateField](../components/date_field.md) for every property.

## DateRangeField

```dart
Form(
  key: _form,
  child: DateRangeField(
    label: 'Stay',
    required: true,
    firstDate: DateTime.now(),
    onSaved: (range) => _stay = range,
  ),
)
```

- The value is Flutter's `DateTimeRange`, both ends at midnight
  (`DateUtils.dateOnly`).
- The text and the spoken value read "start to end"; each date is
  `MaterialLocalizations.formatMediumDate`. Pass `formatter` to word the whole
  range differently.
- The picker is `showDateRangePicker`, opened on the current range with each
  end moved into the allowed range, with its built-in toggle between the
  calendar and typing the dates.
- A start before `firstDate` or an end after `lastDate` fails validation and
  the error names the bound.

See [DateRangeField](../components/date_range_field.md) for every property.

## TimeField

```dart
Form(
  key: _form,
  child: TimeField(
    label: 'Reminder',
    required: true,
    use24HourFormat: true,
    onSaved: (time) => _reminder = time,
  ),
)
```

- The value is a `TimeOfDay`; it has no date and no time zone.
- The default text is `MaterialLocalizations.formatTimeOfDay`; pass
  `formatter` to word it differently.
- `use24HourFormat` forces the 12 or 24 hour clock in the field and in the
  picker. Left `null`, both follow `MediaQuery.alwaysUse24HourFormat` (the
  platform setting).
- The picker offers its built-in toggle between the dial and typing a time;
  `initialEntryMode: TimePickerEntryMode.input` opens it on the typed entry.
- To pick a date and a time, put a `DateField` and a `TimeField` side by side
  and combine them with `DateUtils.dateOnly(date).add(...)` or the
  `DateTime` constructor.

See [TimeField](../components/time_field.md) for every property.
