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

**When:** a `SubmitButton` has no `Form` above it. A debug build asserts when
the button is built; a release build reports it with
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

## AdaptiveShell needs at least two destinations.

**When:** an `AdaptiveShell` was given fewer than two `destinations`. An
assertion in debug builds, checked in `initState` and when the arguments
change; a release build skips it.

**Why:** Material's navigation bar, rail and drawer need two or more places to
make sense, and `NavigationBar` asserts it. A release build shows only the
body (and the `title`, if any) until there are two.

**Fix:** pass two or more destinations, or do not use the shell for a
single-place screen:

```dart
AdaptiveShell(
  destinations: const [
    ShellDestination(icon: Icon(Icons.home), label: 'Home'),
    ShellDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
  ],
  selectedIndex: 0,
  onSelected: go,
  body: page,
)
```

## AdaptiveShell.selectedIndex is out of range.

**When:** `selectedIndex` is negative or not below the number of
destinations, for instance after the list shrank. An assertion in debug
builds; a release build skips it.

**Why:** the index picks the highlighted destination. A release build selects the
nearest valid one meanwhile, so the screen still builds.

**Fix:** keep the index within `0` to `destinations.length - 1`; clamp it
where the destinations change:

```dart
final index = selected.clamp(0, destinations.length - 1);
```

## LayoutBuilder does not support returning intrinsic dimensions.

**When:** a `ResponsiveGrid` or a `ListDetailLayout` sits under a parent that
asks for intrinsic sizes: `IntrinsicWidth`, `IntrinsicHeight`, a `Table`, or a
`DataTable` cell.

**Why:** both read their width with a `LayoutBuilder`, which cannot answer an
intrinsic-size question.

**Fix:** give them a fixed size from outside, and keep intrinsic parents away
from them:

```dart
SizedBox(width: 600, height: 400, child: ListDetailLayout(/* ... */))
```

## ResponsiveGrid or ListDetailLayout has the wrong number of columns or throws

**When:** a `ResponsiveGrid` is placed in a horizontal scroll view or an
unbounded `Row`: it lays out one tile width per child instead of following the
window. A `ListDetailLayout` in the same place throws an unbounded-width
error.

**Why:** both follow the width they are given, not the window's, so they need
a bounded width.

**Fix:** wrap them in a bounded width (`Expanded`, `SizedBox(width: ...)`), or
use `context.windowSize` yourself to pick the layout.

## CountBadge.count must not be negative.

**When:** in a debug build, a `CountBadge` is built with a negative `count`.

**Why:** a count is a quantity. A release build does not assert: it treats the
negative count as 0 and hides the badge.

**Fix:** clamp or compute it before the badge.

```dart
CountBadge(count: math.max(0, unread), child: const Icon(Icons.mail_outline))
```

## CountBadge.max must be positive.

**When:** in a debug build, a `CountBadge` is built with `max` of 0 or less.

**Why:** `max` is the largest number written out before `<max>+`; 0 would
make every count read `0+`. A release build treats `max` as 1.

**Fix:** pass 1 or more, or leave the default of 99.

```dart
CountBadge(count: unread, max: 9, child: const Icon(Icons.mail_outline))
```
