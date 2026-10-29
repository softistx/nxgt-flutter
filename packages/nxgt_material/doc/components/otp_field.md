# OtpField

Library: `package:nxgt_material/fields.dart`

A field for a one-time code: a row of digit slots drawn over one real text input.

## When to use it

For the code of a text message, an email or an authenticator app. It is one `TextFormField` whose text is invisible, laid over `length` slots of 48 dp (not one input per digit), so the platform keeps native paste, the number pad and `AutofillHints.oneTimeCode`: the code of an incoming SMS is offered above the keyboard. For any other number use `NumberField`; for a PIN that must stay hidden use `PasswordField`.

Only digits are kept. A paste such as `12-34 56 78` becomes `123456`, cut at `length`. `onCompleted` fires once each time the code reaches `length` digits (again only after it went incomplete), and never submits the form. A field that starts complete does not fire. A programmatic change of `controller` that completes the code fires `onCompleted` too, and `onCompleted` fires before `onChanged`.

## Example

```dart
OtpField(
  label: 'Verification code',
  helperText: 'Sent by SMS',
  required: true,
  onCompleted: (code) => verify(code),
)
```

Inside a `Form`, an incomplete code fails with `fieldsOtpIncomplete` ("Enter all 6 digits"), an empty one with `fieldsRequired` when `required`, then your `validator` runs. An empty optional field is valid.

## Layout

The row is at most `length * 48 + (length - 1) * 8` dp wide (328 dp for 6 digits). The slots are 48 dp high; they narrow below 48 dp wide when the field has less than 328 dp (6 digits). Text is never scaled. `length` is 1 to 12. The slots stay left to right in a right-to-left layout, like the digits they show. The label sits above the slots; the helper or error text sits under them.

## Accessibility

- A screen reader sees one text field named by `label`; the slots are hidden from it. The error text is shown under the slots.
- Each slot is 48 dp high and up to 48 dp wide; the whole row is one touch target that focuses the input.
- The next slot to fill is outlined while focused; an error outlines every slot in the error colour and the message is shown as text, so colour is never the only cue.
- A disabled field is not focusable.
- Keyboard `number`, autofill `AutofillHints.oneTimeCode`, autocorrect and suggestions off.
- Errors: `fieldsRequired`, `fieldsOtpIncomplete` (fr and en).

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The label above the slots, read by screen readers. |
| `length` | `int` | Number of digits, 1 to 12. Default `6`. |
| `onCompleted` | `ValueChanged<String>?` | Called once when the code reaches `length` digits. |
| `onChanged` | `ValueChanged<String>?` | Called with the digits at every edit. |
| `onSaved` | `FormFieldSetter<String>?` | Called by `FormState.save`. |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the enclosing `Form`. |
| `validator` | `FormFieldValidator<String>?` | Extra validator, run after the built-in ones. |
| `controller` | `TextEditingController?` | Controls the digits. |
| `focusNode` | `FocusNode?` | The focus node of the input. |
| `enabled` | `bool` | Whether the field accepts input. Default `true`. |
| `helperText` | `String?` | Shown under the slots while there is no error. |
| `autofocus` | `bool` | Focus on first show. Default `false`. |
| `required` | `bool` | An empty value is an error. Default `false`. |
