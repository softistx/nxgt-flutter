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
