# EmptyState

Library: `package:nxgt_material/feedback.dart`

What a screen or a list shows when there is nothing to show yet: an icon, a
heading, a sentence and an optional action, centred.

## When to use it

Under a list, a table or a screen whose data loaded but is empty, ideally with
an action that creates the first item. Inside an [AsyncView](async_view.md) it
is shown for you. For a transient message use [InlineAlert](inline_alert.md).

## Example

```dart
EmptyState(
  title: 'No invoices',
  message: 'Create the first one.',
  action: FilledButton(onPressed: create, child: const Text('New invoice')),
)
```

`EmptyState()` alone says "Nothing here yet" in the app's locale.

## Accessibility

The heading is a semantics header; the whole block has the semantics role
`status` and is a live region (on two nested nodes, since Flutter refuses both
on one), so a list that becomes empty is announced. On the web the role alone is announced, so the live region applies only on the other platforms and the text is spoken once. The icon is decorative and hidden from
screen readers. The action keeps its own button semantics and 48 dp target.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `title` | `String?` | Heading; defaults to the localized `feedbackEmptyTitle`. |
| `message` | `String?` | Sentence; defaults to the localized `feedbackEmptyMessage`. |
| `icon` | `Widget?` | Decorative illustration; defaults to an inbox icon. |
| `action` | `Widget?` | Call to action under the message. |
