# ErrorState

Library: `package:nxgt_material/feedback.dart`

What a screen or a list shows when its data failed to load: an icon, a
heading, a sentence and a "Retry" button.

## When to use it

When the failure blocks the whole region. Retry is an
[AsyncButton](async_button.md): it spins until your future completes and
ignores presses meanwhile. Inside an [AsyncView](async_view.md) it is shown for
you. For a failure next to a form or a table use
[InlineAlert](inline_alert.md); for the outcome of an action use a toast.

## Example

```dart
ErrorState(onRetry: () => controller.reload())
```

Do not put a raw exception in `message`: show a sentence the user can act on
and log the error elsewhere.

## Accessibility

The heading is a semantics header and the block has the semantics role `alert`
and is a live region (on two nested nodes), so the failure is announced. On the web the role alone is announced, so the live region applies only on the other platforms and the text is spoken once. The retry button is a labelled button with a 48 dp target; if
`onRetry` throws, the error is reported through `FlutterError.reportError` (see
[troubleshooting](../troubleshooting.md)).

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `title` | `String?` | Heading; defaults to the localized `feedbackErrorTitle`. |
| `message` | `String?` | Sentence; defaults to the localized `feedbackErrorMessage`. |
| `onRetry` | `Future<void> Function()?` | Runs the retry; `null` hides the button. |
| `retryLabel` | `String?` | Overrides the localized "Retry". |
