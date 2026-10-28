# Toast (`context.showToast`)

Library: `package:nxgt_material/feedback.dart`

A short message over the screen, as a method on `BuildContext`. It builds on
Material 3's `SnackBar` and `ScaffoldMessenger` and does not redefine them.

## When to use it

For the outcome of something the user just did ("Saved", "Deleted, Undo").
A message that must stay belongs in an [InlineAlert](inline_alert.md). A new
toast replaces the one on screen. It needs a `Scaffold` and a
`ScaffoldMessenger` above the context (a `MaterialApp` has both).

## Example

```dart
context.showToast('Invoice deleted', actionLabel: 'Undo', onAction: restore);

context.showToast('Saved', tone: FeedbackTone.success);
```

Without a `tone` it is the theme's plain snackbar. With one it is tinted with
`context.tones` (a `ThemeSpec` theme is required) and drawn with the tone's
icon. It returns the `ScaffoldFeatureController`, so `.close()` and `.closed`
work as for any snackbar.

## Accessibility

A `SnackBar` is a live region, so the message is announced when it shows. A
toast with a tone is read as "<tone>: <message>" ("Erreur: ..." in French),
since colour says nothing to a screen reader. The action keeps a 48 dp target.
Mind `duration` (4 s by default): a user who needs more time should get an
`InlineAlert`, or `dismissible: true` with a longer duration.

## Parameters

| Name | Type | Description |
| --- | --- | --- |
| `message` | `String` | The text. |
| `tone` | `FeedbackTone?` | `null` is the plain snackbar. |
| `actionLabel`, `onAction` | `String?`, `VoidCallback?` | A snackbar action; both or neither. |
| `duration` | `Duration` | Time on screen; defaults to 4 s. |
| `dismissible` | `bool` | Adds a close icon. |
