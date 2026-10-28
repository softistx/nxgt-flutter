# SplitButton

Library: `package:nxgt_material/actions.dart`

A main action with a menu of related actions beside it. Material 3 has no
split button.

## When to use it

When one action is the usual choice ("Save") and a few siblings ("Save as
draft", "Save and close") are worth keeping one tap away. For a plain list of
actions use `MenuAnchor` or `PopupMenuButton`.

## Example

```dart
SplitButton(
  label: 'Save',
  icon: const Icon(Icons.save),
  onPressed: save,
  menuChildren: [
    MenuItemButton(onPressed: saveDraft, child: const Text('Save as draft')),
    MenuItemButton(onPressed: saveAndClose, child: const Text('Save and close')),
  ],
)
```

## Accessibility

- Two buttons: the main one named by `label`, and the arrow whose tooltip and
  semantic tooltip is the localized "More options" (`actionsMoreOptions`).
- Both targets are 48 dp; the menu is a `MenuAnchor`, so arrow keys, Escape and
  focus return work as for any Material menu.
- The arrow reports expanded or collapsed, so a screen reader says whether the
  menu is open.
- The corners come from `context.radii` (`xl` outside, `xs` between the two
  parts), with the Material 3 Expressive defaults when the theme has no
  `RadiusScale`.
- The arrow stays enabled when `onPressed` is null, so the menu is still reachable.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The main action's text. |
| `onPressed` | `VoidCallback?` | The main action; `null` disables the main part only. |
| `menuChildren` | `List<Widget>` | The menu entries, usually `MenuItemButton`s. |
| `icon` | `Widget?` | Shown before the label. |
| `menuTooltip` | `String?` | Overrides the localized "More options". |
