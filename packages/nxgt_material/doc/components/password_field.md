# PasswordField

Library: `package:nxgt_material/fields.dart`

A text field for a password with a show/hide button, built on `TextFormField`.

## When to use it

For sign-in, sign-up and password change. The text is obscured, never autocorrected or suggested, and offered to the platform password manager; `newPassword: true` makes it offer to generate one.

## Example

```dart
PasswordField(label: 'Password', required: true)

PasswordField(label: 'New password', newPassword: true, minLength: 8)
```

## Accessibility

- The label names the field; an error is exposed as the field's hint with a
  `validationResult` of invalid, so a screen reader reads "label, error" when
  the field is focused, and the error text is shown under the field.
- A disabled field is not focusable.
- Exposed as an obscured text field while hidden.
- The visibility button is a 48 dp toggle with the tooltip "Show password" / "Hide password" (`fieldsShowPassword`, `fieldsHidePassword`, fr and en), a selected state, and is inert when the field is disabled.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The floating label, read by screen readers. |
| `controller` | `TextEditingController?` | Controls the text; exclusive with `initialValue`. |
| `initialValue` | `String?` | The starting text. |
| `focusNode` | `FocusNode?` | The focus node of the input. |
| `onChanged` | `ValueChanged<String>?` | Called at every edit. |
| `onSaved` | `FormFieldSetter<String>?` | Called by `FormState.save`. |
| `onFieldSubmitted` | `ValueChanged<String>?` | Called on keyboard submit. |
| `validator` | `FormFieldValidator<String>?` | Extra validator, run after the built-in ones. |
| `autovalidateMode` | `AutovalidateMode?` | `null` follows the enclosing `Form`. |
| `enabled` | `bool` | Whether the field accepts input. Default `true`. |
| `helperText` | `String?` | Shown under the field while there is no error. |
| `hintText` | `String?` | Placeholder while empty and focused. |
| `required` | `bool` | An empty value is an error. Default `false`. |
| `minLength` | `int?` | Fewest characters accepted. |
| `newPassword` | `bool` | Autofill hint `newPassword` instead of `password`. |
| `initiallyVisible` | `bool` | Start with the text shown. |
| `textInputAction` | `TextInputAction` | Default `done`. |
