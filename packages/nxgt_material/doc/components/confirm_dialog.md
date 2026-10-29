# ConfirmDialog

Library: `package:nxgt_material/overlays.dart`

A dialog that asks the user to confirm an action, shown with
`context.confirm`, which answers `true` or `false`.

## When to use it

Before an action that is hard to undo or that the user may have triggered by
mistake: deleting a record, leaving with unsaved changes, sending to many
people. For a message that needs no answer use `context.showToast` or an
`InlineAlert`; for a form in a dialog use `context.showFormDialog`; for other
content use `showDialog` directly. It is a dialog at every window size (no bottom sheet on
compact), built on Material 3's `AlertDialog`.

## Example

```dart
import 'package:nxgt_material/overlays.dart';

final deleted = await context.confirm(
  title: 'Delete invoice?',
  message: 'The invoice and its payments are removed. This cannot be undone.',
  confirmLabel: 'Delete',
  destructive: true,
  onConfirm: () => repository.delete(invoice.id),
);
if (deleted) context.showToast('Invoice deleted');
```

`onConfirm` is optional. Without it, confirming pops `true` at once.

## Behaviour

- **Answer.** Confirm pops `true` (after `onConfirm` succeeded); Cancel,
  Escape, a tap on the barrier and the system back gesture pop `false`.
- **`onConfirm`.** It runs through an `AsyncButton`: the confirm action shows a
  spinner and ignores further presses until the future completes. While it
  runs, Cancel is disabled and the dialog cannot be dismissed: there is no way
  out of the dialog, so give the future a timeout. If it throws,
  the error is reported with `FlutterError.reportError` (see
  [troubleshooting](../troubleshooting.md#while-running-an-asyncbutton-action)),
  and the dialog stays open so the user can retry or cancel. Show the failure
  to the user yourself by catching inside `onConfirm`.
- **`destructive`.** The confirm action is drawn with the error tone
  (`context.tones.error`, AA in light and dark; the theme's disabled look
  applies when disabled) and the focus starts on Cancel. Otherwise the focus
  starts on Confirm.
- **Strings.** Cancel and Confirm are localized (`actionsCancel`,
  `actionsConfirm`); `confirmLabel` replaces Confirm. Reword them with
  `NxgtMaterialLocalizationsDelegate(reword:)`.

## Accessibility

The title names the dialog route (`scopesRoute` and `namesRoute`, as
`AlertDialog` does on Android, Windows, Linux and the web; iOS and macOS speak
the title as the first element). Both actions are 48 dp targets on every
platform, including macOS. Focus returns to the control that opened the
dialog when it closes. A long message scrolls, also at text scale 2 on a 360 dp
window. Layout follows the text direction.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `title` | `String` | The question, also the name of the dialog. Must not be empty. |
| `message` | `String` | What happens if the user confirms; scrolls when long. |
| `confirmLabel` | `String?` | Label of the confirm action; the localized "Confirm" when `null`. |
| `destructive` | `bool` | Error tone on the confirm action and initial focus on Cancel. Default `false`. |
| `onConfirm` | `Future<void> Function()?` | The work of the confirm action; the dialog pops `true` when it completes. |

`context.confirm` takes the same arguments and returns `Future<bool>`. It
throws without a `Navigator` above, as `showDialog` does.
