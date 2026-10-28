# CopyButton

Library: `package:nxgt_material/actions.dart`

An icon button that copies a value to the clipboard and shows a check mark for
a moment.

## When to use it

Next to an identifier, a code, a token or a link the user will paste elsewhere.
For a generic icon action use `IconButton`.

## Example

```dart
Row(
  children: [
    const SelectableText('INV-2026-0042'),
    CopyButton(
      value: 'INV-2026-0042',
      onCopied: () => debugPrint('copied'),
    ),
  ],
)
```

## Accessibility

- Named "Copy", then "Copied" (French: "Copier", "Copié") through
  `context.materialL10n.actionsCopy` / `actionsCopied`; `tooltip` overrides the
  first. The same text is the tooltip on hover and long press.
- A live region, so a screen reader announces the change to "Copied".
- The touch target is 48 x 48 dp; it is reachable and activated from the
  keyboard like any `IconButton`.

## Errors

If the clipboard refuses the write, the error goes to `FlutterError.onError`
(see [troubleshooting](../troubleshooting.md)), `onCopied` is not called and
no check mark is shown.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `value` | `String` | The text put on the clipboard. |
| `onCopied` | `VoidCallback?` | Called once the text is on the clipboard. |
| `resetAfter` | `Duration` | How long the check mark stays; 2 seconds by default. |
| `tooltip` | `String?` | Overrides the localized "Copy". |
