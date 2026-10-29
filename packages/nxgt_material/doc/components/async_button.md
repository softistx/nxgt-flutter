# AsyncButton

Library: `package:nxgt_material/actions.dart`

A Material 3 button for an asynchronous action: it shows a spinner and ignores
further presses until the returned `Future` completes.

## When to use it

Whenever a press starts a request (save, submit, delete) and the user must not
trigger it twice. For a synchronous action use `FilledButton`, `OutlinedButton`
or `TextButton` directly. `AsyncButton` builds on them: `variant` picks which.

## Example

```dart
AsyncButton(
  label: 'Save',
  icon: const Icon(Icons.save),
  onPressed: () => repository.save(draft),
)
```

Hold the state yourself (a bloc, a provider) with `loading`:

```dart
AsyncButton(label: 'Save', loading: state.isSaving, onPressed: cubit.save)
```

## Accessibility

- Read as a button named by `label`; while busy its value is the localized
  "Loading" (`context.materialL10n.feedbackLoading`) and it is a live region,
  so the change is spoken.
- It stays focusable and enabled while busy, so keyboard focus is not lost; the
  press is simply ignored. It is disabled only when `onPressed` is null.
- The touch target is 48 dp high (Material tap-target padding).
- An error thrown by `onPressed` is reported with `FlutterError.reportError`;
  the button becomes idle again. Catch it in `onPressed` to show a message.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The text shown, also read by screen readers. |
| `onPressed` | `Future<void> Function()?` | The action; `null` disables the button. |
| `icon` | `Widget?` | Shown before the label; replaced by the spinner while busy. |
| `variant` | `AsyncButtonVariant` | `filled` (default), `tonal`, `outlined`, `text`. |
| `loading` | `bool?` | Forces the busy state; `null` tracks `onPressed` itself. |
| `autofocus` | `bool` | Takes the focus when first built. Default `false`. |
