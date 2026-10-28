# nxgt_material

Material 3 components for Flutter that fill what the framework leaves out:
adaptive layout, fields and forms, feedback states, themes. Intent-named,
accessible, French and English.

> Status: pre-0.1. Components are arriving category by category toward 0.1
> (theme, localization and actions are in); see the [roadmap](docs/roadmap.md).

Runs on Android, iOS, web, macOS, Windows and Linux.

## Install

```sh
flutter pub add nxgt_material
```

## Use

One library per category. Import the one you need, or the barrel:

```dart
import 'package:nxgt_material/fields.dart';
// or everything:
import 'package:nxgt_material/nxgt_material.dart';
```

| Library | What is in it |
| --- | --- |
| `actions.dart` | Buttons and menus that trigger something |
| `collections.dart` | Lists, tables, grids and trees of records |
| `dates.dart` | Date, time and range pickers and their formatting |
| `display.dart` | Cards, stats, badges, avatars |
| `feedback.dart` | Empty, loading and error states, toasts, banners, progress |
| `fields.dart` | Single-value inputs built on `FormField` |
| `forms.dart` | Form scaffolding: sections, validation summary, submit bar |
| `l10n.dart` | French and English strings, delegate, `context.materialL10n` (also re-exported by `nxgt_material.dart`) |
| `layout.dart` | Adaptive shell, breakpoints, pane layouts, spacing |
| `media.dart` | Images, galleries, players, file previews |
| `overlays.dart` | Dialogs, sheets, popovers, tooltips |
| `selection.dart` | Dropdowns, segmented and chip groups |
| `theme.dart` | Seeded color schemes, presets, tones, radius, motifs |

## Theme

A Material 3 theme from a seed colour, with the presets, tones, radius and
motifs of the React library `@nxgt/material`:

```dart
import 'package:nxgt_material/theme.dart';

MaterialApp(
  theme: ThemePresets.ocean.light(),
  darkTheme: ThemePresets.ocean.dark(),
);

// anywhere below:
final done = context.tones.success; // color, onColor, container, onContainer
```

See the [theme guide](docs/guide/theme.md).

## Localization

French and English strings for every component. Add one delegate:

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
  supportedLocales: NxgtMaterialLocalizations.supportedLocales,
);
```

Read a string with `context.materialL10n.actionsConfirm`. Any other locale
falls back to English. Override single strings by subclassing the wrapper:

```dart
class MyStrings extends NxgtMaterialLocalizationsWrapper {
  new(super.base);

  @override
  String get actionsRetry => 'Try again';
}

// in localizationsDelegates:
const NxgtMaterialLocalizationsDelegate(reword: MyStrings.new),
```

See the [localization guide](docs/guide/localization.md).

## Actions

`package:nxgt_material/actions.dart`, built on the Material 3 buttons:

| Component | What it adds |
| --- | --- |
| `AsyncButton` | A button whose async action shows a spinner and ignores presses until done |
| `CopyButton` | Copies a value to the clipboard, shows a check mark |
| `SplitButton` | A main action plus a menu of related actions |
| `LoadMoreButton` | "Show more" for paginated lists, hidden when nothing is left |

```dart
import 'package:nxgt_material/actions.dart';

// A busy state while the future runs; presses are ignored meanwhile.
AsyncButton(label: 'Save', onPressed: () => repository.save(draft))

// Copies to the clipboard, shows a check mark.
const CopyButton(value: 'INV-2026-0042')

// A main action plus a menu of siblings.
SplitButton(
  label: 'Save',
  onPressed: save,
  menuChildren: [
    MenuItemButton(onPressed: saveDraft, child: const Text('Save as draft')),
  ],
)

// "Show more" under a paginated list; hidden when hasMore is false.
LoadMoreButton(hasMore: page.hasNext, onPressed: controller.loadNextPage)
```

Pages: [AsyncButton](docs/components/async_button.md),
[CopyButton](docs/components/copy_button.md),
[SplitButton](docs/components/split_button.md),
[LoadMoreButton](docs/components/load_more_button.md).

## Fields and forms

`package:nxgt_material/fields.dart` and `forms.dart`, on Flutter's `Form` and
`FormField` (no form library):

| Component | What it adds |
| --- | --- |
| `EmailField` | Email keyboard, autofill and validation |
| `PasswordField` | Obscured text with a localized show/hide toggle |
| `PhoneField` | Phone keypad, character filter and validation |
| `NumberField` | Numeric keypad, comma or point, min and max |
| `TextAreaField` | Growing multi-line text with an optional counter |
| `FormSection` | A heading and its fields |
| `SubmitButton` | Validates, saves, then awaits the action |
| `Validators` | `required`, `email`, `minLength`, `maxLength`, `phone`, `number`, `compose`, localized |

```dart
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/forms.dart';

Form(
  child: Column(
    spacing: 16,
    children: [
      FormSection(
        title: 'Account',
        children: [
          const EmailField(label: 'Email', required: true),
          const PasswordField(label: 'Password', newPassword: true, minLength: 8),
        ],
      ),
      SubmitButton(label: 'Create account', onSubmit: () => api.signUp()),
    ],
  ),
)

// The same rules on any TextFormField:
final v = Validators.of(context);
TextFormField(validator: v.compose([v.required(), v.minLength(3)]));
```

Guide: [Forms](docs/guide/forms.md). Pages:
[EmailField](docs/components/email_field.md),
[PasswordField](docs/components/password_field.md),
[PhoneField](docs/components/phone_field.md),
[NumberField](docs/components/number_field.md),
[TextAreaField](docs/components/text_area_field.md),
[FormSection](docs/components/form_section.md),
[SubmitButton](docs/components/submit_button.md).

## Naming rule

- **No `nxgt` prefix.** A component is called by what it is for: `StatCard`,
  `EmailField`, `ConfirmDialog`.
- **Never redefine an M3 widget name.** Flutter's Material 3 widgets stay the
  base; this package never re-wraps `FilledButton`, `Card` or `TextField` under
  its own name. It adds what is missing, under an intent name.

## Documentation

- [Theme](docs/guide/theme.md)
- [Forms](docs/guide/forms.md)
- [Localization](docs/guide/localization.md)
- [Roadmap](docs/roadmap.md)
- [Troubleshooting](docs/troubleshooting.md)
- `docs/components/`: one page per component
- Live catalogue: Widgetbook, published on GitHub Pages from `develop`.

## License

MIT, see [LICENSE](LICENSE).
