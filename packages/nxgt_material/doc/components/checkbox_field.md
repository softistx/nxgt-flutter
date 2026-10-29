# CheckboxField

Library: `package:nxgt_material/selection.dart`

A single checkbox with its label, as a `FormField<bool>`.

## When to use it

The "accept the terms" case: one box that may have to be checked. The whole
row, label included, is the tap target. For a box in a list of options, or
without form behaviour, use Material's `CheckboxListTile`.

## Example

```dart
CheckboxField(
  label: 'I accept the terms of service',
  required: true,
  helperText: 'You can read them on our website',
  onChanged: (accepted) => setState(() => _accepted = accepted ?? false),
)
```

Inside a `Form`, `validate`, `save` and `reset` work as for any field. With
`required`, an unchecked box fails with the localized `fieldsRequired` string
("This field is required" / "Ce champ est obligatoire"). `validator` runs
after it and can add its own message. `autovalidateMode` follows the `Form`
when left `null`.

## Accessibility

One node reads the label and the checked state; a tap on it or on the label
toggles. The tile is full width and at least 48 dp high on every platform,
also under the compact desktop density, wraps a long label at large text
sizes and mirrors in right-to-left. The error under the tile has the `alert`
role; outside the web it is also a live region so it is announced when it
appears (on the web the role alone speaks, to avoid a double announcement).
The box is drawn in the error colour. A disabled field ignores taps and is
skipped by validation.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The text beside the box, tappable, read by screen readers. |
| `required` | `bool` | The box must be checked to be valid. Default `false`. |
| `initialValue` | `bool?` | Starting value, restored by `Form.reset`. Default `false`. |
| `onChanged` | `ValueChanged<bool?>?` | Called at every change. |
| `onSaved` | `FormFieldSetter<bool>?` | Called by `FormState.save`. |
| `validator` | `FormFieldValidator<bool>?` | Extra validator, after `required`. |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the `Form`. |
| `enabled` | `bool` | Whether it accepts input. Default `true`. |
| `helperText` | `String?` | A hint under the tile, replaced by the error. |
