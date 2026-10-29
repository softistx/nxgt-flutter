# UrlField

Library: `package:nxgt_material/fields.dart`

A text field for a web address, built on `TextFormField`.

## When to use it

Whenever the value is an http or https address: it sets the URL keyboard, the `url` autofill hint, no capitalization, no autocorrect, the `next` action and the localized validation. The scheme is optional, so `example.com` is valid. Hosts must be domain names, including international ones (`bücher.de`); a bare IP address, `localhost` and credentials (`user:pw@host`) are rejected. The field keeps the text as typed; call `UrlField.normalize` on the value you save. For other text use `TextFormField`.

## Example

```dart
UrlField(
  label: 'Website',
  required: true,
  onSaved: (value) => site = UrlField.normalize(value ?? ''),
)
```

`UrlField.normalize(text)` trims the text and adds `https://` when there is no scheme (`example.com` gives `https://example.com`). It returns `null` for anything `Validators.url` rejects (`ftp://x.com`, `localhost`, `http://`).

## Accessibility

- The label names the field; an error is exposed as the field's hint with a
  `validationResult` of invalid, so a screen reader reads "label, error" when
  the field is focused, and the error text is shown under the field.
- A disabled field is not focusable.
- Keyboard `url`, autofill `AutofillHints.url`, `TextCapitalization.none`, autocorrect off.
- Errors: `fieldsRequired`, `fieldsInvalidUrl` (fr and en).

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

| Static | Description |
| --- | --- |
| `UrlField.normalize(String) -> String?` | Trimmed URL with `https://` added when missing, or `null` when invalid. |
