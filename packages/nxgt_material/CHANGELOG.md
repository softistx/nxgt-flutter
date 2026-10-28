## Unreleased

- `feedback.dart`: `EmptyState`, `LoadingState` (a static icon under reduced motion), `ErrorState` (retry through `AsyncButton`), `AsyncView<T>` (switches between them and your content over a `Future` or an `AsyncSnapshot`), `InlineAlert` and `FeedbackTone` (info, success, warning, error; role `alert` or `status`, tone spoken first, AA tone colours) and `context.showToast` (a tinted, announced `SnackBar` with an optional action). New strings `feedbackToneInfo`, `feedbackToneSuccess`, `feedbackToneWarning`, `feedbackToneError` in fr and en.

- `fields.dart`: `EmailField`, `PasswordField` (show/hide toggle), `PhoneField`, `NumberField` and `TextAreaField`, built on `TextFormField` with the right keyboard, autofill hints and input action, and `Validators` (`required`, `email`, `minLength`, `maxLength`, `phone`, `number`, `compose`) with localized messages. `forms.dart`: `FormSection` and `SubmitButton` (validates, saves and awaits an action through `AsyncButton`). New strings `fieldsInvalidPhone`, `fieldsInvalidNumber`, `fieldsMinValue`, `fieldsMaxValue`, `fieldsShowPassword`, `fieldsHidePassword` in fr and en.

- `actions.dart`: `AsyncButton` (a Material 3 button whose async action shows a spinner and ignores presses until done, four variants), `CopyButton` (copies a value, shows a check mark, announced to screen readers), `SplitButton` (main action plus a `MenuAnchor` of related actions) and `LoadMoreButton` (an outlined `AsyncButton` for paginated lists). New strings `actionsCopy`, `actionsCopied`, `actionsMoreOptions` in fr and en.

- `theme.dart`: `ThemeSpec` builds a Material 3 light and dark `ThemeData` from a seed colour (`ColorScheme.fromSeed`), with the 14 presets of `@nxgt/material` (`ThemePresets`), AA-solved `Tones` (primary, secondary, tertiary, success, info, warning, error, neutral, and app tones), `RadiusScale`, `ThemeFonts` and `ThemeMotif` as `ThemeExtension`s, `context.tones` / `radii` / `fonts` / `motif`, and a `TokenSheet` widget.

- `l10n.dart`: French and English strings (`gen-l10n`, ARBs in `lib/l10n/`) for actions, field validation, feedback states and adaptive navigation. `NxgtMaterialLocalizationsDelegate` (falls back to English for any other locale, takes `reword:` to override strings through a `NxgtMaterialLocalizationsWrapper` subclass), `NxgtMaterialLocalizations.supportedLocales` and `context.materialL10n`. Widgetbook gets a locale addon.

## 0.0.1

- Package skeleton: one library per category, no component yet.
