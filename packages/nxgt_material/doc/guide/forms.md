# Forms

`nxgt_material` builds on Flutter's own `Form` and `FormField`; there is no
form library to adopt. The fields are `TextFormField`s with the right keyboard,
autofill hints and input action already set, and a `SubmitButton` ties the
form to an `AsyncButton`.

```dart
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/forms.dart';

Form(
  child: Column(
    spacing: 16,
    children: [
      FormSection(
        title: 'Account',
        children: [
          const EmailField(label: 'Email', required: true),
          const PasswordField(label: 'Password', newPassword: true, minLength: 8),
        ],
      ),
      SubmitButton(label: 'Create account', onSubmit: () => api.signUp(draft)),
    ],
  ),
)
```

## Components

| Component | Library | What it adds |
| --- | --- | --- |
| `EmailField` | fields | Email keyboard, autofill, validation |
| `PasswordField` | fields | Obscured text, show/hide toggle, new-password hint |
| `UrlField` | fields | URL keyboard, autofill, validation, `normalize` |
| `OtpField` | fields | One-time code: digit slots, paste, SMS autofill, `onCompleted` |
| `PhoneField` | fields | Phone keypad, character filter, validation |
| `NumberField` | fields | Numeric keypad, comma or point, min and max |
| `TextAreaField` | fields | Growing multi-line text with an optional counter |
| `DateField` | dates | A date picked in Material's date picker, as a `FormField<DateTime>` |
| `SwitchField` | selection | An on/off switch tile as a `FormField<bool>`; off by default |
| `FormSection` | forms | A heading and its fields |
| `SubmitButton` | forms | Validate, save, then await a submit action |

## Validating

Each field has `required` and validates its own kind of value. Add your own
rule with `validator`; it runs after the built-in ones and the first message
wins. Fields show errors per the `Form`'s `autovalidateMode` (or their own).
Validation messages are localized, see the [localization guide](localization.md).

## Validators

The same rules are available for any `TextFormField`:

```dart
final v = Validators.of(context);

TextFormField(
  validator: v.compose([v.required(), v.minLength(3), v.maxLength(30)]),
)
```

`Validators.of(context)` reads `context.materialL10n` once, so build the set in
`build` and it follows a locale change on the next rebuild. Outside a widget
(a unit test) construct it with the strings: `Validators(strings)`, where
`strings` is a `NxgtMaterialLocalizations`.

| Validator | Fails when |
| --- | --- |
| `required()` | the value is null or blank |
| `email()` | a non-empty value is not an email |
| `url()` | a non-empty value is not an http or https web address (scheme optional, dotted host) |
| `minLength(n)` / `maxLength(n)` | the length is below / above `n` |
| `phone()` | a non-empty value is not a phone number (7 to 15 digits) |
| `number(min:, max:)` | a non-empty value is not a number or is out of range |
| `compose(list)` | the first of `list` that fails; `null` entries are skipped |

Except `required`, validators accept an empty value, so an optional field is
valid until something is typed. `NumberField.parse(text)` (the one public parser, which `Validators.number` also uses) parses a number
typed with a comma or a point. A comma is the decimal separator and there are
no thousands separators: `1,234` is 1.234 and `1,234.5` is invalid, as are
`0x1A` and `1e3`.

## Accessibility

Every field has a label, announces its error with the field and marks it
invalid, and a disabled field is not focusable. The password toggle is a 48 dp
button with a localized label and a selected state.

## Submitting

`SubmitButton` calls `FormState.validate`, then `save`, then your `onSubmit`.
While it runs the button shows "Loading" to screen readers and ignores
further presses. On an invalid form it scrolls to and focuses the first
invalid field in tree order, and the SDK announces the error. Put it inside the `Form` (a descendant of it); otherwise it reports an error (see
[troubleshooting](../troubleshooting.md)).
