# FormDialog

Library: `package:nxgt_material/overlays.dart`

A form in a dialog, shown with `context.showFormDialog`: full-screen on a
compact window, a dialog from the medium size up. It validates the form, runs
your async submit, and asks before discarding changes.

## When to use it

To create or edit a record without leaving the page: a new invoice, a profile,
a few settings. For a yes or no question use `context.confirm`; for content
that is not a form (filters, a picker) use `context.showAdaptiveSheet`; for a
whole screen of fields use a page with a `Form` and a `SubmitButton`.

## Example

```dart
import 'package:nxgt_material/overlays.dart';

final invoice = await context.showFormDialog<Invoice>(
  title: 'New invoice',
  submitLabel: 'Create',
  builder: (context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Customer'),
        validator: Validators.of(context).required(),
      ),
    ],
  ),
  onSubmit: () => repository.create(draft),
);
if (invoice != null) context.showToast('Invoice created');
```

`onSubmit` returns the value the dialog pops, so the caller gets `T?`: the
value after a successful submit, `null` when the user closed the dialog.

## Behaviour

- **Layout.** Under 600 dp (`WindowSize.compact`, read when the dialog
  opens) it is a full-screen route with a top app bar: a close button, the
  title and the submit action. From the medium size up it is a dialog up to
  560 dp wide with Cancel and the submit action at the bottom. The content
  scrolls; the keyboard never covers the focused field.
- **Submit.** The content is wrapped in a `Form`. The submit action is a
  `SubmitButton`: an invalid form stays open, shows its errors and calls
  nothing; a valid one is saved (`FormState.save`) and `onSubmit` runs with a
  spinner.
- **Failure.** If `onSubmit` throws, the error is reported with
  `FlutterError.reportError` (see
  [troubleshooting](../troubleshooting.md#while-running-an-asyncbutton-action))
  and the dialog stays open so the user can retry. Show the failure yourself by
  catching inside `onSubmit`.
- **Locked while it works.** From the press of Submit until the dialog is gone
  (its exit animation included) the close button, Cancel, Escape, the barrier
  and the back gesture do nothing, so the page beneath cannot be popped by
  mistake. There is no way out while `onSubmit` runs: give the future a
  timeout.
- **Discarding changes.** Once a field changes (`Form.onChanged`), closing with
  the close button, Cancel, Escape, a tap on the barrier or the back gesture
  asks "Discard changes?" through `context.confirm(destructive: true)`. Cancel
  keeps the dialog open; Discard closes it and returns `null`. A dialog nobody
  edited closes at once with `null`. A field that is changed and changed back
  still counts as changed.
- **Strings.** `overlaysDiscardTitle`, `overlaysDiscardMessage` and
  `overlaysDiscardConfirm` are localized (fr, en); `submitLabel` replaces the
  default "Confirm". Reword them with
  `NxgtMaterialLocalizationsDelegate(reword:)`.
- **Motion.** The route and the dialog open and close without animation when
  the platform asks for reduced motion.

## Accessibility

The title is a semantics header and names the route once (the `AlertDialog`
route on the dialog, the app bar title on the full-screen layout; iOS and
macOS speak the title as the first element). The close button is labelled
"Close". Every action is a 48 dp target on every platform, including macOS.
Focus stays in the dialog and returns to the control that opened it when it
closes. At text scale 2 on a 360 dp window the content scrolls without
overflow. Layout follows the text direction.

## Properties

`FormDialog<T>` is public to be placed in a Widgetbook use case or a golden
test; it needs a `Navigator` and a `Material` ancestor. Prefer
`context.showFormDialog`.

| Name | Type | Description |
| --- | --- | --- |
| `title` | `String` | The title, also the name of the dialog. Must not be empty. |
| `child` | `Widget` | The fields, placed in a `Form`. |
| `onSubmit` | `Future<T> Function()` | Called with the form valid and saved; its value is the one the dialog pops. |
| `submitLabel` | `String?` | Label of the submit action; the localized "Confirm" when `null`. |
| `fullscreen` | `bool` | Draw the full-screen layout instead of the dialog. `showFormDialog` sets it from the window size. Needs a bounded height. Default `false`. |

`context.showFormDialog<T>({title, builder, onSubmit, submitLabel})` takes a
`WidgetBuilder` in place of `child` and returns `Future<T?>`.
