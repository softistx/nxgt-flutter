# Localization

`nxgt_material` ships its strings in French and English (`gen-l10n`, ARB files
in `lib/l10n/`). Components read them through `context.materialL10n`, so an app
only adds one delegate.

## Add it to the app

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nxgt_material/l10n.dart';

MaterialApp(
  localizationsDelegates: const [
    NxgtMaterialLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: NxgtMaterialLocalizations.supportedLocales, // en, fr
);
```

`flutter_localizations` comes from the Flutter SDK; add it to the app's
`pubspec.yaml` (`flutter_localizations: {sdk: flutter}`).

## Read a string

```dart
Text(context.materialL10n.actionsRetry);
```

Without the delegate, `context.materialL10n` answers in English instead of
throwing, so a component never breaks for a missing setup (it is then not
translated). In debug builds it prints one `debugPrint` line the first time it
falls back, naming the delegate to add.

## Unsupported locale

`NxgtMaterialLocalizationsDelegate` supports every locale: anything other than
`en` and `fr` gets the English strings.

## Override a string

Subclass `NxgtMaterialLocalizationsWrapper`, override the getters you word
differently, and give the delegate the subclass:

```dart
class MyStrings extends NxgtMaterialLocalizationsWrapper {
  new(super.base);

  @override
  String get actionsRetry => switch (localeName) {
    'fr' => 'Recommencer',
    _ => 'Try again',
  };
}

MaterialApp(
  localizationsDelegates: const [
    NxgtMaterialLocalizationsDelegate(reword: MyStrings.new),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: NxgtMaterialLocalizations.supportedLocales,
);
```

The snippet needs `package:flutter_localizations/flutter_localizations.dart`
and `package:nxgt_material/l10n.dart`. The barrel `nxgt_material.dart` exports
the same names, so either import works. The package depends on `intl`, which
`gen-l10n` needs; the app does not have to add it.

Give `reword` a constructor tear-off such as `MyStrings.new`, never a closure
written in `build`: the delegate reloads when `reword` is not identical to the
previous one, so a fresh closure reloads the strings on every rebuild.

Every other string keeps the package's text, in the locale that was resolved.
**Why a wrapper and not a map of keys:** a typo in a getter name is a compile
error, parameterised strings (`fieldsMinLength(count)`) stay typed, and an
app that adds a string later gets the compiler's help.

## Keys

Keys are `<area><Name>` and follow the `material.*` keys of `@nxgt/material`:
`actions*` (confirm, cancel, close, save, retry, clear, show more/less,
`actionsCopy`, `actionsCopied`, `actionsMoreOptions`),
`fields*` (required, invalid email, invalid phone, invalid number, min/max length
with plural, min/max value, show/hide password), `feedback*`
(loading, empty and error title/message, and the spoken tone words
`feedbackToneInfo`, `feedbackToneSuccess`, `feedbackToneWarning`,
`feedbackToneError`), `layout*` (open/close navigation).

## Adding a string (contributors)

1. Add the key to `lib/l10n/nxgt_material_en.arb` (the template) and
   `nxgt_material_fr.arb`.
2. Run `melos run gen`; the generated files are committed under
   `lib/src/l10n/generated/`.
3. Forward it in `NxgtMaterialLocalizationsWrapper`. The generated class
   declares every string abstract, so the build fails until you forward it;
   the specs also compare English and French and fail on a missing
   translation.
