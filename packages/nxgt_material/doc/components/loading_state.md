# LoadingState

Library: `package:nxgt_material/feedback.dart`

What a screen or a list shows while its data loads: a progress indicator and a
caption, centred.

## When to use it

For a whole screen or region that has nothing to show yet. For one button use
[AsyncButton](async_button.md); for a bar tied to a known amount of work use
Flutter's `LinearProgressIndicator` (progress indicators are not wrapped by
this package). Inside an [AsyncView](async_view.md) it is shown for you.

## Example

```dart
const LoadingState(message: 'Fetching invoices')
```

## Accessibility

The block has the semantics role `status` and is a live region (on two nested
nodes), so "Loading" (or your message) is spoken when it
appears; the spinner itself is hidden from screen readers. With reduced motion
(`MediaQuery.disableAnimations`, the system "remove animations" setting) the
spinner is replaced by a static hourglass icon and the caption stays.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `message` | `String?` | Caption; defaults to the localized `feedbackLoading`. |
