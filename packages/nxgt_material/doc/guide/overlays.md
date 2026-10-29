# Overlays: dialog or sheet

`nxgt_material` has three overlays in `package:nxgt_material/overlays.dart`.
Which one to use depends on what you show, not on the screen size; the
components choose the layout for the window themselves.

| You show | Use | Layout |
| --- | --- | --- |
| A question the user must answer (delete, leave, send) | `context.confirm` | A dialog at every window size |
| Content to look at or pick from (a filter, a color list, a detail) | `context.showAdaptiveSheet` | A bottom sheet on compact, a side sheet from medium up |
| Fields to fill in and submit | `context.showFormDialog` | Full-screen on compact, a dialog up to 560 dp from medium up |

The rule in one line: **a confirmation is a dialog, content is a sheet, a form
is a `FormDialog`.** Never put a form in an `AdaptiveSheet` (it has no submit
action and no discard guard), and never ask a yes/no question in a sheet.

All three need a `Navigator` above (any `MaterialApp` has one), return a
`Future`, and read the window size when they open. They are built on Flutter's
`AlertDialog`, `showDialog`, `showModalBottomSheet` and `showGeneralDialog`.

## Confirm: a dialog

`context.confirm` answers `true` when the user confirmed and `false` when they
cancelled or dismissed it. It never returns `null`.

```dart
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/overlays.dart';

Future<void> deleteInvoice(BuildContext context, String id) async {
  final deleted = await context.confirm(
    title: 'Delete invoice?',
    message: 'This cannot be undone.',
    confirmLabel: 'Delete',
    destructive: true,
    onConfirm: () => repository.delete(id),
  );
  if (deleted && context.mounted) context.showToast('Invoice deleted');
}
```

- `onConfirm` is optional. With one, the confirm button shows a spinner and
  ignores presses until the future completes, then the dialog pops `true`.
  While it runs the dialog cannot be closed, so give the future a timeout. If
  it throws, the error is reported with `FlutterError.reportError` and the
  dialog stays open.
- `destructive: true` draws the confirm action with the error tone and starts
  the focus on Cancel, so a stray Enter does not delete. Otherwise the focus
  starts on Confirm.
- Keep the title a question and the confirm label a verb ("Delete", not "OK").

## Content: an adaptive sheet

`context.showAdaptiveSheet` shows a title, a close button and your content.
"Adaptive" means the window size, not the platform:

- **Compact** (under 600 dp): a modal bottom sheet with a drag handle, up to
  90 % of the window height, kept above the keyboard.
- **Medium and up**: a side sheet on the end edge (the right in left-to-right
  text, the left in right-to-left), 400 dp wide (or the window width if it is
  narrower) and full height, sliding in.

The content scrolls when it is taller than the room. The size is read when the
sheet opens and does not change if the window is resized meanwhile.

```dart
import 'package:nxgt_material/overlays.dart';

Future<void> pickColor(BuildContext context) async {
  final color = await context.showAdaptiveSheet<Color>(
    title: 'Pick a color',
    builder: (context) => Column(
      children: [
        for (final c in [Colors.teal, Colors.indigo, Colors.orange])
          ListTile(
            leading: CircleAvatar(backgroundColor: c),
            title: Text(c.toString()),
            onTap: () => Navigator.pop(context, c),
          ),
      ],
    ),
  );
  if (color != null) apply(color);
}
```

Pop with `Navigator.pop(context, value)` from the builder's context to return
a value. The close button, Escape, a tap on the barrier and the back gesture
return `null`, so `null` always means "nothing chosen". A sheet is for
content that can be dismissed without loss; if closing it would lose typed
work, use a `FormDialog`.

`AdaptiveSheet` is the content widget on its own (header plus scrolling body);
it draws no surface. Use it directly only in a catalogue or a golden test.

## Form: a form dialog

`context.showFormDialog` wraps your fields in a `Form` and adds the submit
action:

- **Compact**: a full-screen route with a top app bar that holds the close
  button, the title and the submit action.
- **Medium and up**: a dialog up to 560 dp wide with Cancel and the submit
  action at the bottom.

The submit action is a `SubmitButton`: it validates the form (an invalid form
stays open and nothing is sent), saves it, then awaits `onSubmit`. The value
`onSubmit` returns is the value the dialog pops. If `onSubmit` throws, the
error is reported and the dialog stays open and usable. While `onSubmit` runs
the dialog cannot be closed, so give it a timeout.

```dart
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/overlays.dart';

Future<void> newInvoice(BuildContext context) async {
  var client = '';
  final created = await context.showFormDialog<Invoice>(
    title: 'New invoice',
    submitLabel: 'Create',
    builder: (context) => Column(
      spacing: 16,
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Client'),
          validator: Validators.of(context).required(),
          onSaved: (value) => client = value ?? '',
        ),
        const NumberField(label: 'Amount', required: true, min: 0),
      ],
    ),
    onSubmit: () => repository.create(Invoice(client: client)),
  );
  if (created != null && context.mounted) context.showToast('Invoice created');
}
```

(`Validators` and `NumberField` are in `fields.dart`; `showToast` is in
`feedback.dart`.) Read the fields in `onSaved` or from controllers you own;
`onSubmit` runs after the form is validated and saved.

### The discard-changes guard

Once any field changes (`Form.onChanged`), closing the dialog by any route
(the close button, Cancel, Escape, a tap on the barrier or the back gesture)
first asks "Discard changes?" through `context.confirm`. Choosing the
destructive action closes the dialog and returns `null`; Cancel keeps the
dialog open with the typed values. A dialog nobody edited closes at once. You
write nothing for this; do not add your own `PopScope` around the fields.

## Focus, back and Escape

| | Confirm | Sheet | Form dialog |
| --- | --- | --- | --- |
| Focus starts on | Cancel if `destructive`, else Confirm | The sheet (close button first) | A field with `autofocus`, else the dialog itself |
| Escape, barrier tap, back | Pop `false` | Pop `null` | Pop `null`, after the discard question if edited |
| While busy | Locked | Not applicable | Locked |
| Focus returns to | The control that opened it | The control that opened it | The control that opened it |

Focus stays inside an open overlay (Tab does not reach the page beneath). The
"locked" states also swallow Escape, so a key press cannot pop the page under
a dialog that is animating out.

## Screen readers

- A confirm dialog and a form dialog are named by their title; a side sheet is
  a route named by its title. A bottom sheet is Flutter's modal route (named
  generically), and its title is reachable as the heading.
- The sheet title is a semantics header. Close buttons have a localized label
  and a 48 dp target; so do the confirm, Cancel and submit actions.
- The submit button announces "Loading" while it runs, and an invalid form
  focuses its first invalid field, whose error the platform announces.
- Under reduced motion (`MediaQuery.disableAnimations`) the sheets and the
  full-screen form open without a slide.
- Strings are French and English; add the delegate described in the
  [localization guide](localization.md).

Pages: [ConfirmDialog](../components/confirm_dialog.md),
[AdaptiveSheet](../components/adaptive_sheet.md),
[FormDialog](../components/form_dialog.md). See also the
[forms guide](forms.md).
