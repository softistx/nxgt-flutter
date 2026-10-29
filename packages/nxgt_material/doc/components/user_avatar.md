# UserAvatar

Library: `package:nxgt_material/display.dart`

A person's picture, or their initials on a colour the name always gives, with
an optional presence dot. Built on `CircleAvatar`.

## When to use it

Lists of people, comment authors, a profile header. The initials show when
there is no `image`, while it loads and if it fails to load, so the avatar is
never blank. The fill is one of the theme's tones (primary, secondary,
tertiary, success, info, warning) picked from the name with a stable hash, so
the same name gets the same colour on every platform and run; text on it meets
AA contrast in light and dark. An empty name draws a generic person icon on the
neutral tone. For a status word use [StatusIndicator](status_indicator.md).

## Example

```dart
UserAvatar(name: 'Ada Lovelace') // "AL"

UserAvatar(
  name: user.name,
  image: NetworkImage(user.photoUrl),
  size: 56,
  presence: AvatarPresence.online,
)
```

## Accessibility

A screen reader says the name and then the localized presence: "Ada Lovelace,
Online" ("Ada Lovelace, En ligne" in French). The picture and the initials are
excluded from semantics; the dot's meaning is in the spoken label, not only in
its colour. The strings are `displayPresenceOnline`, `displayPresenceAway`,
`displayPresenceBusy` and `displayPresenceOffline`, which an app can reword
through `NxgtMaterialLocalizationsWrapper`. An empty name with no presence
says nothing.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `name` | `String` | The person's name: initials, tone and spoken label. Empty draws a person icon. |
| `image` | `ImageProvider?` | The picture; the initials show while it loads or if it fails. |
| `size` | `double` | The diameter, default 40; must be positive. |
| `presence` | `AvatarPresence?` | `online`, `away`, `busy` or `offline`; a dot on the corner, none by default. |
