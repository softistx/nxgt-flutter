# TextAreaField

Library: `package:nxgt_material/fields.dart`

A multi-line text field that grows with its content, built on `TextFormField`.

## When to use it

For comments and descriptions. The keyboard action is a new line, so submit with a `SubmitButton`. With `maxLength` it shows a counter and stops typing at the limit.

## Example

```dart
TextAreaField(label: 'Notes', maxLength: 500)
```

## Accessibility

- The label names the field; an error is exposed as the field's hint with a
  `validationResult` of invalid, so a screen reader reads "label, error" when
  the field is focused, and the error text is shown under the field.
- A disabled field is not focusable.
- Exposed as a multi-line text field.

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
| `minLines` | `int` | Height at rest. Default `3`. |
| `maxLines` | `int` | Height it grows to. Default `8`. |
| `maxLength` | `int?` | Character limit and counter. |
