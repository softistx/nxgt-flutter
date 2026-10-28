# SubmitButton

Library: `package:nxgt_material/forms.dart`

The button that submits the enclosing `Form`, built on `AsyncButton`.

## When to use it

Instead of wiring `validate`, `save` and a busy state by hand. Pressing it validates the form; if valid it saves and awaits `onSubmit`, showing the spinner so the form cannot be sent twice; if invalid nothing is sent, the fields show their errors, and it scrolls to the first invalid field and focuses it. It must be inside a `Form` (a descendant; see [troubleshooting](../troubleshooting.md#submitbutton-was-used-outside-a-form)).

## Example

```dart
Form(
  child: Column(
    children: [
      const EmailField(label: 'Email', required: true),
      SubmitButton(label: 'Send', onSubmit: () => api.send(email)),
    ],
  ),
)
```

## Accessibility

- Same semantics as `AsyncButton`: a button named by `label`, "Loading" as its value while busy, a 48 dp target, focusable while busy.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The text shown. |
| `onSubmit` | `Future<void> Function()?` | Called with the form valid and saved; `null` disables. |
| `icon` | `Widget?` | Replaced by the spinner while busy. |
| `variant` | `AsyncButtonVariant` | Default `filled`. |
