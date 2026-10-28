# InlineAlert

Library: `package:nxgt_material/feedback.dart`

A message that stays in the page next to what it is about, in four tones
(`FeedbackTone.info`, `success`, `warning`, `error`).

## When to use it

A form error summary, a warning above a table, a confirmation under a button.
For the outcome of an action that fades away use a toast
(`context.showToast`); for an empty or failed region use
[EmptyState](empty_state.md) or [ErrorState](error_state.md). It is neither a
`SnackBar` nor a `MaterialBanner`.

It reads `context.tones`: the theme's tones under a `ThemeSpec`, tones
generated from the colour scheme under a plain `ThemeData`. Tone colours are
AA-solved pairs (container on on-container).

## Example

```dart
InlineAlert(
  tone: FeedbackTone.warning,
  title: 'Check the address',
  message: 'The postcode does not match the city.',
  action: TextButton(onPressed: fix, child: const Text('Fix it')),
  onDismiss: () => setState(() => show = false),
)
```

## Accessibility

A live region with the semantics role `alert` for `warning` and `error`, and
`status` for `info` and `success`. A screen reader says the tone ("Error",
"Succès" in French) before the title and the message, so the meaning never
rests on colour alone. The icon is decorative. The close button is labelled
with the localized "Close" and keeps a 48 dp target; the action keeps its own
button semantics.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `message` | `String` | The text of the alert. |
| `title` | `String?` | Bold first line. |
| `tone` | `FeedbackTone` | Colours, icon and announcement; defaults to `info`. |
| `icon` | `IconData?` | Replaces the tone's icon. |
| `action` | `Widget?` | Under the text, usually a `TextButton`. |
| `onDismiss` | `VoidCallback?` | Shows a close button; the alert does not hide itself. |
