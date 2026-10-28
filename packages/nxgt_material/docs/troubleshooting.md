# Troubleshooting

Entries are added as problems are found. Each one is headed by the exact
message you will search for, then when it happens, why, and the fix.

## nxgt_material: no NxgtMaterialLocalizationsDelegate found, using English. Add it to localizationsDelegates.

**When:** in a debug build, the first time a component reads
`context.materialL10n` below an app that did not add the delegate. Printed once.

**Why:** the strings come from `NxgtMaterialLocalizationsDelegate`. Without it
the package falls back to English instead of throwing, so French users see
English text.

**Fix:**

```dart
MaterialApp(
  localizationsDelegates: const [
    NxgtMaterialLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: NxgtMaterialLocalizations.supportedLocales,
);
```

See the [localization guide](guide/localization.md).

## while running an AsyncButton action

**When:** the `onPressed` of an `AsyncButton` (or `LoadMoreButton`) threw or
its future failed. The text is the `context` of the report in the console.

**Why:** the button reports the error to `FlutterError.onError` and does not
rethrow it, so it never reaches the zone's uncaught handler. The button becomes
idle again. A `loading:` forced by the caller is not cleared by the button: the
caller owns that state.

**Fix:** catch inside `onPressed` and show a message, then rethrow only what
you want reported:

```dart
AsyncButton(
  label: 'Save',
  onPressed: () async {
    try {
      await repository.save(draft);
    } on SaveFailed catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  },
)
```

## while copying to the clipboard

**When:** `CopyButton` could not write to the clipboard (a web page without
permission or focus, a platform that refuses).

**Why:** `Clipboard.setData` threw. The error goes to `FlutterError.onError`,
`onCopied` is not called and no check mark is shown, so the user is not told
the copy worked.

**Fix:** on the web, serve the page over HTTPS and copy from a user gesture (a
tap on the button is one). Elsewhere, listen to `FlutterError.onError` to show
your own message.

## SubmitButton was used outside a Form.

**When:** pressing a `SubmitButton` that has no `Form` above it. Reported with
`FlutterError.reportError` (through the button's `AsyncButton`), once per press.

**Why:** the button validates and saves the enclosing `Form`; with none there
is nothing to validate, so it refuses to send.

**Fix:** wrap the fields and the button in a `Form`:

```dart
Form(
  child: Column(
    children: [
      const EmailField(label: 'Email'),
      SubmitButton(label: 'Send', onSubmit: send),
    ],
  ),
)
```

## Validation messages stay in the old language after a locale change

**When:** a `Validators.of(context)` set was built once (in `initState`, a
static field or a view model) and the app locale changes later.

**Why:** the set reads `context.materialL10n` when it is built and keeps those
strings. Only a set built in `build` is rebuilt with the new locale.

**Fix:** build it in `build`, where the locale is a dependency:

```dart
@override
Widget build(BuildContext context) {
  final v = Validators.of(context);
  return TextFormField(validator: v.compose([v.required(), v.minLength(3)]));
}
```

## An error message is still in the old language after a locale change

**When:** a field already showing an error when the locale changes.

**Why:** a `FormField` keeps the message it computed at the last validation;
nothing recomputes it when the locale changes.

**Fix:** revalidate after the change, for example
`formKey.currentState?.validate()`, or use
`AutovalidateMode.onUserInteraction` so the next edit refreshes it.

## The theme has no ThemeFonts.

**When:** `context.fonts` (or `context.motif`, with `ThemeMotif`) is read under
a `ThemeData` that did not come from `ThemeSpec`. Thrown as a `FlutterError`
while building.

**Why:** fonts and motifs are the app's own choices; there is nothing sensible
to guess. `context.tones` and `context.radii` do not throw: they fall back to
tones generated from the colour scheme and to the Material 3 Expressive radii.

**Fix:** build the theme with `ThemeSpec` or a preset, or add the extension to
`ThemeData.extensions`:

```dart
MaterialApp(
  theme: ThemePresets.ocean.light(),
  darkTheme: ThemePresets.ocean.dark(),
);
```

## showToast: actionLabel and onAction go together.

**When:** `context.showToast` was given an `actionLabel` without an `onAction`,
or the reverse. An assertion in debug builds.

**Why:** a snackbar action needs both its label and its callback; one without
the other is a button that does nothing or has no name.

**Fix:** pass both, or neither.

## No ScaffoldMessenger widget found.

**When:** `context.showToast` is called from a context with no `Scaffold`-capable
`ScaffoldMessenger` above it, for example above the `MaterialApp`.

**Why:** a toast is a `SnackBar` of the nearest `ScaffoldMessenger`; `MaterialApp`
provides one, so the context must be below it.

**Fix:** call it from a context under the `MaterialApp` (use a `Builder` if the
call is in the same `build` that creates the app).

## AsyncView: Give AsyncView either a future or a snapshot, not both or neither.

**When:** an `AsyncView` was built with both `future` and `snapshot`, or with
neither. An assertion in debug builds.

**Why:** the view follows one source of truth.

**Fix:** pass `future`, or `snapshot`, not both.

## while loading the data of an AsyncView

**When:** the `future` given to an `AsyncView` failed. The text is the `context`
of the report in the console. Reported once per future.

**Why:** the view shows an `ErrorState` (never the exception) and reports the
error to `FlutterError.onError` once, from `initState` or `didUpdateWidget`,
not from `build`. A failure of a `snapshot` is not reported: the caller owns
it. A future replaced before it failed is not reported either.

**Fix:** handle the error where the future is made if it is expected, or word
the message with `errorBuilder`. Keep the future in state; a future created
inline in `build` restarts, and is reported again, on every rebuild:

```dart
late final Future<List<Invoice>> invoices = repository.invoices();

AsyncView<List<Invoice>>(
  future: invoices,
  errorBuilder: (context, error, stack) =>
      ErrorState(message: error is Offline ? 'You are offline.' : null),
  builder: (context, items) => InvoiceList(items),
)
```
