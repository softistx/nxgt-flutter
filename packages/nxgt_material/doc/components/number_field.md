# NumberField

Library: `package:nxgt_material/fields.dart`

A text field for a number with an optional range, built on `TextFormField`.

## When to use it

For a quantity, an age, a price. It refuses any character that is not part of a number and accepts a comma as the decimal separator. Read the value with `NumberField.parse`, never `num.parse`.

The rule is strict: a comma or a point is the decimal separator, there are no thousands separators (`1,234` is 1.234), and hexadecimal and exponent forms (`0x1A`, `1e3`) are refused. See the [forms guide](../guide/forms.md).

## Example

```dart
NumberField(
  label: 'Quantity',
  min: 1,
  max: 99,
  onChanged: (text) => qty = NumberField.parse(text),
)
```

## Accessibility

- The label names the field; an error is exposed as the field's hint with a
  `validationResult` of invalid, so a screen reader reads "label, error" when
  the field is focused, and the error text is shown under the field.
- A disabled field is not focusable.
- Keyboard `numberWithOptions` (signed only when `min` is null or negative, decimal with `allowDecimal`).
- Errors: `fieldsRequired`, `fieldsInvalidNumber`, `fieldsMinValue(min)`, `fieldsMaxValue(max)`, with the bound formatted for the locale (`1,5` in French).

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
| `min` | `num?` | Smallest accepted value. |
| `max` | `num?` | Largest accepted value. |
| `allowDecimal` | `bool` | Default `false`. |
| `textInputAction` | `TextInputAction` | Default `next`. |
