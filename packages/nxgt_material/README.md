# nxgt_material

Material 3 components for Flutter that fill what the framework leaves out:
adaptive layout, fields and forms, feedback states, themes. Intent-named,
accessible, French and English.

> Status: pre-release. The 0.1 content is complete (theme, localization,
> actions, fields, forms, feedback and adaptive layout); see the
> [roadmap](doc/roadmap.md) for what comes next.

Runs on Android, iOS, web, macOS, Windows and Linux.

## Install

```sh
flutter pub add nxgt_material
```

## Use

One library per category, created with its first component. Import the one you need, or the barrel:

```dart
import 'package:nxgt_material/fields.dart';
// or everything:
import 'package:nxgt_material/nxgt_material.dart';
```

| Library | What is in it |
| --- | --- |
| `actions.dart` | Buttons and menus that trigger something |
| `feedback.dart` | Empty, loading and error states, toasts, banners, progress |
| `fields.dart` | Single-value inputs built on `FormField` |
| `forms.dart` | Form scaffolding: sections, validation summary, submit bar |
| `l10n.dart` | French and English strings, delegate, `context.materialL10n` (also re-exported by `nxgt_material.dart`) |
| `layout.dart` | Adaptive shell, breakpoints, pane layouts, spacing |
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

See the [theme guide](doc/guide/theme.md).

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

Read a string with `context.materialL10n.actionsRetry`. Any other locale
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

See the [localization guide](doc/guide/localization.md).

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

Pages: [AsyncButton](doc/components/async_button.md),
[CopyButton](doc/components/copy_button.md),
[SplitButton](doc/components/split_button.md),
[LoadMoreButton](doc/components/load_more_button.md).

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

// A phone number, filtered to what a number can contain.
const PhoneField(label: 'Phone')

// A number in a range; a comma is read as a decimal point.
NumberField(
  label: 'Quantity',
  min: 1,
  max: 99,
  onChanged: (text) => quantity = NumberField.parse(text),
)

// Grows from 3 to 8 lines, with a counter.
const TextAreaField(label: 'Notes', maxLength: 500)

// The same rules on any TextFormField:
final v = Validators.of(context);
TextFormField(validator: v.compose([v.required(), v.minLength(3)]));
```

Guide: [Forms](doc/guide/forms.md). Pages:
[EmailField](doc/components/email_field.md),
[PasswordField](doc/components/password_field.md),
[PhoneField](doc/components/phone_field.md),
[NumberField](doc/components/number_field.md),
[TextAreaField](doc/components/text_area_field.md),
[FormSection](doc/components/form_section.md),
[SubmitButton](doc/components/submit_button.md).

## Feedback

`package:nxgt_material/feedback.dart`. Progress indicators are Flutter's own
(`CircularProgressIndicator`, `LinearProgressIndicator`) and are not wrapped.

| Component | What it adds |
| --- | --- |
| `EmptyState` | Icon, heading, sentence and action for "nothing here yet" |
| `LoadingState` | Spinner and caption; a static icon under reduced motion |
| `ErrorState` | Failure block with a "Retry" `AsyncButton` |
| `AsyncView<T>` | Switches between the three and your content, over a `Future` or an `AsyncSnapshot` |
| `InlineAlert` | An in-page message in four tones, announced as an alert or a status |
| `context.showToast` | A tinted, announced `SnackBar` with an optional action |

```dart
import 'package:nxgt_material/feedback.dart';

// Loading, error with retry, empty and content in one widget.
AsyncView<List<Invoice>>(
  future: repository.invoices(),
  isEmpty: (invoices) => invoices.isEmpty,
  onRetry: reload,
  builder: (context, invoices) => InvoiceList(invoices),
)

// The states on their own.
EmptyState(
  title: 'No invoices',
  action: FilledButton(onPressed: create, child: const Text('New invoice')),
)
const LoadingState()
ErrorState(onRetry: reload)

// An in-page message; tone colours come from the theme (or its colour scheme).
InlineAlert(
  tone: FeedbackTone.warning,
  title: 'Check the address',
  message: 'The postcode does not match the city.',
  onDismiss: hide,
)

// A toast over the Scaffold, replacing the one on screen.
context.showToast('Invoice deleted', actionLabel: 'Undo', onAction: restore);
context.showToast('Saved', tone: FeedbackTone.success);
```

Pages: [EmptyState](doc/components/empty_state.md),
[LoadingState](doc/components/loading_state.md),
[ErrorState](doc/components/error_state.md),
[AsyncView](doc/components/async_view.md),
[InlineAlert](doc/components/inline_alert.md),
[Toast](doc/components/toast.md).

## Layout

`package:nxgt_material/layout.dart`. Built on Flutter's `NavigationBar`,
`NavigationRail` and `NavigationDrawer`, switched by the Material 3 window size
classes; no extra package.

| Component | What it adds |
| --- | --- |
| `WindowSize`, `Breakpoints`, `context.windowSize` | The Material 3 classes (compact 0, medium 600, expanded 840, large 1200, extraLarge 1600) |
| `AdaptiveShell` | Bar on compact (or a drawer), rail on medium, standing drawer on expanded and up; safe areas, keyboard focus, hover |
| `PageBody` | Centred content with a maximum width and gutters per window size |
| `ResponsiveGrid` | Columns by minimum tile width |
| `ListDetailLayout` | List and detail side by side, or one at a time under 648 dp |

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nxgt_material/l10n.dart';
import 'package:nxgt_material/layout.dart';

void main() => runApp(
  MaterialApp(
    localizationsDelegates: const [
      NxgtMaterialLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: NxgtMaterialLocalizations.supportedLocales,
    home: const Home(),
  ),
);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      destinations: const [
        ShellDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        ShellDestination(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
      ],
      selectedIndex: index,
      onSelected: (i) => setState(() => index = i),
      body: SingleChildScrollView(
        child: PageBody(
          child: ResponsiveGrid(
            children: [
              for (var i = 0; i < 6; i++)
                Card(child: SizedBox(height: 80, child: Center(child: Text('Tile $i')))),
            ],
          ),
        ),
      ),
    );
  }
}
```

Read the class anywhere with `context.windowSize`
(`if (context.windowSize == WindowSize.compact) ...`). A list and its detail:
`ListDetailLayout(showDetail: selected != null, onBack: clear, list: ..., detail: ...)`,
see [ListDetailLayout](doc/components/list_detail_layout.md). The shell takes
`title`, `appBar`, `actions`, `floatingActionButton`,
`floatingActionButtonLocation` and `bottomSheet`, and a screen's own
`Scaffold` can nest in `body`.

Guide: [Adaptive layout](doc/guide/adaptive.md). Pages:
[WindowSize](doc/components/window_size.md),
[AdaptiveShell](doc/components/adaptive_shell.md),
[PageBody](doc/components/page_body.md),
[ResponsiveGrid](doc/components/responsive_grid.md),
[ListDetailLayout](doc/components/list_detail_layout.md).

## Naming rule

- **No `nxgt` prefix.** A component is called by what it is for: `StatCard`,
  `EmailField`, `ConfirmDialog`.
- **Never redefine an M3 widget name.** Flutter's Material 3 widgets stay the
  base; this package never re-wraps `FilledButton`, `Card` or `TextField` under
  its own name. It adds what is missing, under an intent name.

## Documentation

- [Theme](doc/guide/theme.md)
- [Forms](doc/guide/forms.md)
- [Localization](doc/guide/localization.md)
- [Adaptive layout](doc/guide/adaptive.md)
- [Roadmap](doc/roadmap.md)
- [Troubleshooting](doc/troubleshooting.md)
- Components, one page each:
  [AdaptiveShell](doc/components/adaptive_shell.md),
  [AsyncButton](doc/components/async_button.md),
  [AsyncView](doc/components/async_view.md),
  [CopyButton](doc/components/copy_button.md),
  [EmailField](doc/components/email_field.md),
  [EmptyState](doc/components/empty_state.md),
  [ErrorState](doc/components/error_state.md),
  [FormSection](doc/components/form_section.md),
  [InlineAlert](doc/components/inline_alert.md),
  [ListDetailLayout](doc/components/list_detail_layout.md),
  [LoadMoreButton](doc/components/load_more_button.md),
  [LoadingState](doc/components/loading_state.md),
  [NumberField](doc/components/number_field.md),
  [PageBody](doc/components/page_body.md),
  [PasswordField](doc/components/password_field.md),
  [PhoneField](doc/components/phone_field.md),
  [ResponsiveGrid](doc/components/responsive_grid.md),
  [SplitButton](doc/components/split_button.md),
  [SubmitButton](doc/components/submit_button.md),
  [TextAreaField](doc/components/text_area_field.md),
  [Toast](doc/components/toast.md),
  [WindowSize](doc/components/window_size.md).
- Live catalogue: Widgetbook, published on GitHub Pages from `develop`.

## License

MIT, see [LICENSE](LICENSE).
