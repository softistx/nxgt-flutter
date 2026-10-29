# CountBadge

Library: `package:nxgt_material/display.dart`

A count on the corner of a widget, on Material 3 `Badge.count`.

## When to use it

Unread messages on an icon, items in a cart. It shows `99+` above `max` and is
hidden at 0 (the child stays). For a dot without a number use Flutter's
`Badge`; for a status word use [StatusIndicator](status_indicator.md).

## Example

```dart
CountBadge(
  count: unread,
  semanticLabel: 'Inbox',
  child: const Icon(Icons.mail_outline),
)

// Cap at 9.
CountBadge(count: 12, max: 9, child: const Icon(Icons.shopping_cart_outlined))
```

## Accessibility

A screen reader says `semanticLabel` and then the localized count, always the
real number even when the badge shows `99+`: "Inbox, 120 items" ("Inbox, 120
éléments" in French). Nothing is added at 0. The string is `displayCount`, a
plural in both languages, that an app can reword through
`NxgtMaterialLocalizationsWrapper`.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `count` | `int` | The number shown; must not be negative. 0 hides the badge. |
| `child` | `Widget` | What the badge sits on, usually an `Icon`. |
| `max` | `int` | Largest number written out, default 99; must be positive. |
| `semanticLabel` | `String?` | Names the child for screen readers. |
