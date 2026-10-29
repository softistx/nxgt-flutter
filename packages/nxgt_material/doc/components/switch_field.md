# SwitchField

Library: `package:nxgt_material/selection.dart`

An on/off switch with its label, as a `FormField<bool>`.

## When to use it

An option that is either on or off and belongs to a form: "Enable
notifications", "Make this profile public". The whole row, label included, is
the tap target. For a switch in a list of settings without form behaviour, use
Material's `SwitchListTile`; for a box that may have to be checked, use
`CheckboxField`.

## Example

```dart
SwitchField(
  label: 'Enable notifications',
  helperText: 'Sent by email, at most once a day',
  onChanged: (on) => setState(() => _notify = on),
)
```

Inside a `Form`, `validate`, `save` and `reset` work as for any field. There is
no `required`: off is a valid answer. When it must be on, add a validator:

```dart
SwitchField(
  label: 'Share my usage data',
  validator: (on) => on == true ? null : 'Turn this on to continue',
)
```

`autovalidateMode` follows the `Form` when left `null`.

## Accessibility

One node reads the label and the on or off state, with the error (or the
helper text) as its hint; a tap on the switch or on the label toggles, and so
does Space on the focused switch. The tile is full width and at least 48 dp
high on every platform, also under the compact desktop density, wraps a long
label at large text sizes and mirrors in right-to-left. The error under the
tile has the `alert` role; outside the web it is also a live region. A
disabled field ignores taps and is skipped by validation.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The text beside the switch, tappable, read by screen readers. |
| `initialValue` | `bool` | Starting value, restored by `Form.reset`. Default `false`. |
| `onChanged` | `ValueChanged<bool>?` | Called at every change. |
| `onSaved` | `FormFieldSetter<bool>?` | Called by `FormState.save`. |
| `validator` | `FormFieldValidator<bool>?` | Validator, for example "must be on". |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the `Form`. |
| `enabled` | `bool` | Whether it accepts input; a disabled field is not validated and shows no error. Default `true`. |
| `focusNode` | `FocusNode?` | The focus node of the switch. |
| `helperText` | `String?` | A hint under the tile, replaced by the error. |
