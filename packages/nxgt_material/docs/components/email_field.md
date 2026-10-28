# EmailField

Library: `package:nxgt_material/fields.dart`

A text field for an email address, built on `TextFormField`.

## When to use it

Whenever the value is an email: it sets the email keyboard, the `email` autofill hint, the `next` action and the localized validation. For other text use `TextFormField`.

## Example

```dart
EmailField(label: 'Email', required: true)
```

## Accessibility

- The label names the field; an error is exposed as the field's hint with a
  `validationResult` of invalid, so a screen reader reads "label, error" when
  the field is focused, and the error text is shown under the field.
- A disabled field is not focusable.
- Keyboard `emailAddress`, autofill `AutofillHints.email`.
- Errors: `fieldsRequired`, `fieldsInvalidEmail` (fr and en).

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
