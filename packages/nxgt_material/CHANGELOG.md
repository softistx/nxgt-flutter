## Unreleased

- `display.dart`: `StatusIndicator` (a dot or the tone icon and a label in AA tone colours from `FeedbackTone`, the tone spoken first) and `CountBadge` (a count on `Badge.count`: `99+` above `max`, hidden at 0, spoken with a plural label; asserts a negative count and a non-positive `max`). New string `displayCount` in fr and en.

## 0.1.0

First release.

- `theme.dart`: `ThemeSpec` builds a Material 3 light and dark `ThemeData` from a seed colour (`ColorScheme.fromSeed`), with the 14 presets of `@nxgt/material` (`ThemePresets`), AA-solved `Tones` (primary, secondary, tertiary, success, info, warning, error, neutral, and app tones), `RadiusScale`, `ThemeFonts` and `ThemeMotif` as `ThemeExtension`s, `context.tones` / `radii` / `fonts` / `motif`, and a `TokenSheet` widget. `context.tones` falls back to `Tones.fromScheme` of the theme's colour scheme (cached per scheme) and `context.radii` to the Material 3 Expressive defaults; `context.fonts` and `context.motif` fall back to `const ThemeFonts()` and `ThemeMotif.none`; `Tones.operator []` returns `ToneColors?`.

- `l10n.dart`: French and English strings (`gen-l10n`, ARBs in `lib/l10n/`) for actions, field validation, feedback states and adaptive navigation. `NxgtMaterialLocalizationsDelegate` (falls back to English for any other locale, takes `reword:` to override strings through a `NxgtMaterialLocalizationsWrapper` subclass), `NxgtMaterialLocalizations.supportedLocales` and `context.materialL10n`. Widgetbook gets a locale addon.

- `actions.dart`: `AsyncButton` (a Material 3 button whose async action shows a spinner and ignores presses until done, four variants), `CopyButton` (copies a value, shows a check mark, announced to screen readers), `SplitButton` (main action plus a `MenuAnchor` of related actions) and `LoadMoreButton` (an outlined `AsyncButton` for paginated lists). New strings `actionsCopy`, `actionsCopied`, `actionsMoreOptions` in fr and en.

- `fields.dart`: `EmailField`, `PasswordField` (show/hide toggle), `PhoneField`, `NumberField` and `TextAreaField`, built on `TextFormField` with the right keyboard, autofill hints and input action, and `Validators` (`required`, `email`, `minLength`, `maxLength`, `phone`, `number`, `compose`) with localized messages; `NumberField.parse` is the public number parser. `forms.dart`: `FormSection` and `SubmitButton` (validates, saves and awaits an action through `AsyncButton`; asserts it is inside a `Form`). New strings `fieldsInvalidPhone`, `fieldsInvalidNumber`, `fieldsMinValue`, `fieldsMaxValue`, `fieldsShowPassword`, `fieldsHidePassword` in fr and en.

- `feedback.dart`: `EmptyState`, `LoadingState` (a static icon under reduced motion), `ErrorState` (retry through `AsyncButton`), `AsyncView<T>` (switches between them and your content over a `Future` or an `AsyncSnapshot`, with an `errorBuilder`; a failed future is reported once), `InlineAlert` and `FeedbackTone` (info, success, warning, error; role `alert` or `status`, tone spoken first, AA tone colours) and `context.showToast` (a tinted, announced `SnackBar` with an optional action). New strings `feedbackToneInfo`, `feedbackToneSuccess`, `feedbackToneWarning`, `feedbackToneError` in fr and en. `EmptyState` and `LoadingState` have the semantics role `status`, `ErrorState` the role `alert`; on the web the role alone is announced, elsewhere a live region speaks, so each is announced once. `context.showToast` comes from the `ToastContext` extension; `InlineAlert.icon` is a `Widget?`.

- `layout.dart`: `WindowSize` and `Breakpoints` (the Material 3 classes, 600 / 840 / 1200 / 1600, shared with `@nxgt/material`) with `context.windowSize`; `AdaptiveShell` (a `NavigationBar` on compact or a modal drawer with `CompactNavigation.drawer`, a `NavigationRail` on medium, a standing `NavigationDrawer` on expanded and wider; safe areas, focus traversal and hover kept) with `ShellDestination`; `PageBody` (maximum width and gutters per window size); `ResponsiveGrid` (columns by minimum tile width); `ListDetailLayout` (two panes above 648 dp, one below, back gesture calls `onBack`). `AdaptiveShell` asserts two destinations or more and `selectedIndex` in range, forwards `appBar`, `actions`, `bottomSheet` and `floatingActionButtonLocation`, keeps the body's state across size classes, honours the text direction for safe areas and closes an open drawer when the window leaves compact; `ListDetailLayout` keeps both panes' state across 648 dp. New string `layoutNavigation` in fr and en. Guide: `doc/guide/adaptive.md`.

- Package: guides, component pages and troubleshooting in `doc/`, `topics`, a `.pubignore`, `intl ^0.20.3`. A category library appears with its first component: 0.1 ships `actions`, `feedback`, `fields`, `forms`, `layout`, `theme` and `l10n`, plus the barrel `nxgt_material.dart`.

## 0.0.1

- Package skeleton: one library per category, no component yet.
