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
translated).

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

const NxgtMaterialLocalizationsDelegate(reword: MyStrings.new);
```

Every other string keeps the package's text, in the locale that was resolved.
**Why a wrapper and not a map of keys:** a typo in a getter name is a compile
error, parameterised strings (`fieldsMinLength(count)`) stay typed, and an
app that adds a string later gets the compiler's help.

## Keys

Keys are `<area><Name>` and follow the `material.*` keys of `@nxgt/material`:
`actions*` (confirm, cancel, close, save, retry, clear, show more/less),
`fields*` (required, invalid email, min/max length with plural), `feedback*`
(loading, empty and error title/message), `layout*` (open/close navigation).

## Adding a string (contributors)

1. Add the key to `lib/l10n/nxgt_material_en.arb` (the template) and
   `nxgt_material_fr.arb`.
2. Run `melos run gen`; the generated files are committed under
   `lib/src/l10n/generated/`.
3. Forward it in `NxgtMaterialLocalizationsWrapper`; the specs compare English
   and French and fail on a missing translation.
