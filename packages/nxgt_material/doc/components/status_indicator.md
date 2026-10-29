# StatusIndicator

Library: `package:nxgt_material/display.dart`

A short status in the page: a dot and a label, in the colours of a tone.

## When to use it

A state next to a record: "Paid", "Late", "Draft". It is not tappable: use a
`Chip` for a filter or a choice, [InlineAlert](inline_alert.md) for a message
that needs a sentence.

It uses `FeedbackTone` (`info`, `success`, `warning`, `error`) and reads
`context.tones`, so the colours are AA-solved pairs (dot and label on the
tone's container) under a `ThemeSpec` or a plain `ThemeData`.

## Example

```dart
const StatusIndicator(label: 'Paid', tone: FeedbackTone.success)

// The tone's icon instead of the dot, so statuses also differ by shape.
const StatusIndicator(label: 'Late', tone: FeedbackTone.error, dot: false)
```

## Accessibility

One node that a screen reader reads as the tone's localized name and then the
label ("Success, Paid"; "Succès, Payé" in French), so the meaning never rests
on colour alone. The dot and the icon are decorative.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The text shown, read after the tone. |
| `tone` | `FeedbackTone` | Colours and spoken tone; defaults to `info`. |
| `dot` | `bool` | `true` (default) draws a dot, `false` the tone's icon. |
