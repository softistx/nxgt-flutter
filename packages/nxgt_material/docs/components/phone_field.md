# PhoneField

Library: `package:nxgt_material/fields.dart`

A text field for a phone number, built on `TextFormField`.

## When to use it

Whenever the value is a phone number. It filters to digits, a leading `+`, spaces, dots, dashes and parentheses, and accepts 7 to 15 digits. It does not reformat; use a phone library for E.164.

## Example

```dart
PhoneField(label: 'Phone', required: true)
```

## Accessibility

- The label names the field; an error is exposed as the field's hint with a
  `validationResult` of invalid, so a screen reader reads "label, error" when
  the field is focused, and the error text is shown under the field.
- A disabled field is not focusable.
- Keyboard `phone`, autofill `AutofillHints.telephoneNumber`.
- Errors: `fieldsRequired`, `fieldsInvalidPhone`.

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
| `textInputAction` | `TextInputAction` | Default `next`. |
