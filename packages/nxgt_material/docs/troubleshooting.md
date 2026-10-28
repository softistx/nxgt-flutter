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
