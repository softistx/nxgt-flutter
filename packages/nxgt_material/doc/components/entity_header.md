# EntityHeader

Library: `package:nxgt_material/display.dart`

The heading of a record page or a sheet: a title, a muted subtitle, a leading
widget, a status and the actions on the entity.

## When to use it

At the top of a customer, order or patient page. For the screen's bar use
`AppBar`; for a row in a list use `ListTile`. `leading` is typically a
`UserAvatar` and `status` a `StatusIndicator`; both are plain widgets.

## Example

```dart
EntityHeader(
  title: 'Ada Lovelace',
  subtitle: 'ada@example.com',
  leading: const UserAvatar(name: 'Ada Lovelace', size: 56),
  status: const StatusIndicator(label: 'Active', tone: FeedbackTone.success),
  actions: [
    EntityAction(label: 'Edit', icon: Icons.edit, onPressed: edit),
    EntityAction(
      label: 'Delete',
      icon: Icons.delete_outline,
      destructive: true,
      onPressed: delete,
    ),
  ],
)
```

## Layout

- From the medium window size (600 dp, `context.windowSize`) the actions are
  `OutlinedButton`s at the end of the row, wrapping on several lines.
- On compact, or when the text scale is above 1.5 (buttons would crowd the
  title), they fold into a `MenuAnchor` opened by a "More options" icon button
  (string `actionsMoreOptions`).
- The buttons share at most half the header's width and wrap; a single label
  wider than that clips.
- A long title or subtitle wraps; nothing overflows at a 2x text scale.
- A `destructive` action uses the error tone (container and on-container
  colours, AA contrast) in both forms.
- Insets and alignment are directional, so it mirrors in right-to-left.

## Accessibility

The title is a semantics header. Each button and menu item is read by its
label; the overflow button is named "More options" (localized) and is 48 dp.
A `null` `onPressed` disables an action.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `title` | `String` | The entity's name, a semantics header. |
| `subtitle` | `String?` | A muted line under the title. |
| `leading` | `Widget?` | Before the text, typically a `UserAvatar`. |
| `status` | `Widget?` | Under the text, typically a `StatusIndicator`. |
| `actions` | `List<EntityAction>` | Buttons or menu items; empty by default. |

`EntityAction`: `label` (required, not empty; see
[troubleshooting](../troubleshooting.md)), `onPressed` (required, `null`
disables), `icon` (`IconData?`), `destructive` (`bool`, default `false`).
