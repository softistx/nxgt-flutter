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

## UserAvatar.size must be positive.

**When:** in a debug build, a `UserAvatar` is built with a `size` of 0 or less.

**Why:** `size` is the avatar's diameter. A release build does not assert: it
draws the avatar at the default size of 40.

**Fix:** pass a positive size, or leave the default.

```dart
UserAvatar(name: user.name, size: 56)
```

## EntityAction.label must not be empty.

**When:** in a debug build, an `EntityAction` is built with an empty `label`.

**Why:** the label is the only name of the button or menu item for a screen
reader. A release build does not assert: `EntityHeader` leaves that action out.

**Fix:** give every action a label.

```dart
EntityAction(label: 'Edit', icon: Icons.edit, onPressed: edit)
```

## EntityHeader.title must not be empty.

**When:** in a debug build, an `EntityHeader` is built with an empty `title`.

**Why:** the title is the heading of the page for a screen reader. A release
build does not assert: the header draws no title.

**Fix:** give the header the name of the entity.

```dart
EntityHeader(title: patient.name, subtitle: patient.email)
```

## ConfirmDialog.title must not be empty.

**When:** in a debug build, a `ConfirmDialog` (or `context.confirm`) is given an
empty `title`.

**Why:** the title is the name of the dialog for a screen reader. A release
build does not assert: the dialog is shown with an empty title and no name.

**Fix:** give the dialog a title that asks the question.

```dart
final ok = await context.confirm(
  title: 'Delete invoice?',
  message: 'This cannot be undone.',
);
```

## AdaptiveSheet.title must not be empty.

**When:** in a debug build, `context.showAdaptiveSheet` (or an `AdaptiveSheet`)
is given an empty `title`.

**Why:** the title is the heading of the sheet and the name of its route for a
screen reader. A release build does not assert: the sheet is shown with an
empty header text and no route name, and the close button still works.

**Fix:** give the sheet a title that says what it is for.

```dart
final result = await context.showAdaptiveSheet<String>(
  title: 'Filters',
  builder: (context) => const FilterForm(),
);
```

## FormDialog.title must not be empty.

**When:** in a debug build, `context.showFormDialog` (or a `FormDialog`) is
given an empty `title`.

**Why:** the title is the heading of the dialog and the name of its route for a
screen reader. A release build does not assert: the dialog is shown with an
empty header text and no route name, and the close and submit actions still
work.

**Fix:** give the dialog a title that says what it is for.

```dart
final invoice = await context.showFormDialog<Invoice>(
  title: 'New invoice',
  builder: (context) => const InvoiceFields(),
  onSubmit: () => repository.create(draft),
);
```

## RadioGroupField.options must have unique values.

**When:** in a debug build, two options of a `RadioGroupField` share a value.

**Why:** the value identifies the option in the group and in the form. A
release build does not assert: the first option with a value is kept, the
later ones with the same value are not shown.

**Fix:** give each option its own value.

```dart
RadioGroupField<String>(
  label: 'Plan',
  options: const [
    ChoiceOption(value: 'monthly', label: 'Monthly'),
    ChoiceOption(value: 'yearly', label: 'Yearly'),
  ],
)
```

## RadioGroupField.initialValue must be one of the options.

**When:** in a debug build, `initialValue` of a `RadioGroupField` is not the
value of any option.

**Why:** nothing could show as chosen. A release build does not assert: no
option is shown as chosen, but the value is still the form's value, so
`required` passes and `onSaved` receives it until the user chooses.

**Fix:** start from a value that is in `options`, or leave it out.

```dart
RadioGroupField<String>(
  label: 'Plan',
  initialValue: 'monthly',
  options: const [ChoiceOption(value: 'monthly', label: 'Monthly')],
)
```

## RadioGroupField.options must not be empty.

**When:** in a debug build, `options` of a `RadioGroupField` is an empty list.

**Why:** a group without options cannot be answered. A release build does not
assert: only the group label is shown, and `required` can never be satisfied.

**Fix:** pass at least one option, or do not show the field.

```dart
if (plans.isNotEmpty)
  RadioGroupField<Plan>(label: 'Plan', options: plans)
```

## CheckboxGroupField.options must have unique values.

**When:** in a debug build, two options of a `CheckboxGroupField` share a value.

**Why:** see [RadioGroupField.options must have unique values.](#radiogroupfieldoptions-must-have-unique-values).
A release build keeps the first option of each value.

**Fix:** give each option its own value.

## CheckboxGroupField.initialValue must only hold values of the options.

**When:** in a debug build, `initialValue` of a `CheckboxGroupField` holds a
value that is the value of no option.

**Why:** nothing could show as chosen for it. A release build does not assert:
that value is not shown, but it stays in the form's value, is reported after
the first change (at the end of the set) and counts for `required`.

**Fix:** start from values that are in `options`.

```dart
CheckboxGroupField<String>(
  label: 'Topics',
  initialValue: const {'news'},
  options: const [ChoiceOption(value: 'news', label: 'News')],
)
```

## CheckboxGroupField.options must not be empty.

**When:** in a debug build, `options` of a `CheckboxGroupField` is an empty list.

**Why:** see [RadioGroupField.options must not be empty.](#radiogroupfieldoptions-must-not-be-empty).
A release build shows only the label.

**Fix:** pass at least one option, or do not show the field.

## ChoiceChipsField.options must have unique values.

**When:** in a debug build, two options of a `ChoiceChipsField` share a value.

**Why:** see [RadioGroupField.options must have unique values.](#radiogroupfieldoptions-must-have-unique-values).
A release build keeps the first option of each value.

**Fix:** give each option its own value.

## ChoiceChipsField.options must not be empty.

**When:** in a debug build, `options` of a `ChoiceChipsField` is an empty list.

**Why:** see [RadioGroupField.options must not be empty.](#radiogroupfieldoptions-must-not-be-empty).
A release build shows only the label.

**Fix:** pass at least one option, or do not show the field.

## ChoiceChipsField.initialValue must be one of the options.

**When:** in a debug build, `initialValue` of a `ChoiceChipsField` is not the
value of any option.

**Why:** no chip could show as chosen. A release build does not assert: no chip
is shown as chosen, but the value is still the form's value, so `required`
passes and `onSaved` receives it until the user chooses.

**Fix:** start from a value that is in `options`, or leave it out.

```dart
ChoiceChipsField<String>(
  label: 'Size',
  initialValue: 'm',
  options: const [ChoiceOption(value: 'm', label: 'Medium')],
)
```

## FilterChipsField.options must have unique values.

**When:** in a debug build, two options of a `FilterChipsField` share a value.

**Why:** see [RadioGroupField.options must have unique values.](#radiogroupfieldoptions-must-have-unique-values).
A release build keeps the first option of each value.

**Fix:** give each option its own value.

## FilterChipsField.options must not be empty.

**When:** in a debug build, `options` of a `FilterChipsField` is an empty list.

**Why:** see [RadioGroupField.options must not be empty.](#radiogroupfieldoptions-must-not-be-empty).
A release build shows only the label.

**Fix:** pass at least one option, or do not show the field.

## FilterChipsField.initialValue must only hold values of the options.

**When:** in a debug build, `initialValue` of a `FilterChipsField` holds a value
that is the value of no option.

**Why:** see [CheckboxGroupField.initialValue must only hold values of the options.](#checkboxgroupfieldinitialvalue-must-only-hold-values-of-the-options).
A release build keeps that value in the form's value, reports it at the end of
the set after the first change, and counts it for `required`.

**Fix:** start from values that are in `options`.

## SelectField.options must have unique values.

**When:** in a debug build, two options of a `SelectField` share a value.

**Why:** see [RadioGroupField.options must have unique values.](#radiogroupfieldoptions-must-have-unique-values).
A release build keeps the first option of each value.

**Fix:** give each option its own value.

## SelectField.options must not be empty.

**When:** in a debug build, `options` of a `SelectField` is an empty list.

**Why:** see [RadioGroupField.options must not be empty.](#radiogroupfieldoptions-must-not-be-empty).
A release build shows an empty menu, and `required` can never be satisfied.

**Fix:** pass at least one option, or do not show the field.

## SelectField.initialValue must be one of the options.

**When:** in a debug build, `initialValue` of a `SelectField` is not the value
of any option.

**Why:** the field shows the label of the chosen option, so the value must be
one of them. A release build keeps the value in the form but shows an empty
field.

**Fix:** start from a value that is in `options`, or from `null`.

```dart
SelectField<String>(label: 'Country', options: countries, initialValue: 'fr')
```

## SearchField.controller and SearchField.initialValue must not both be given.

**When:** in a debug build, a `SearchField` gets both a `controller` and an
`initialValue`.

**Why:** the starting text belongs to the controller you pass; the field owns
a controller only when none is given. A release build uses the controller and
ignores `initialValue`.

**Fix:** set the text on your controller, or drop the controller.

```dart
final controller = TextEditingController(text: 'amoxi');
SearchField(controller: controller, onChanged: filter)
```

## SearchField.debounce must not be negative.

**When:** in a debug build, `debounce` of a `SearchField` is below zero.

**Why:** a pause cannot be negative. A release build emits at once, as
`Duration.zero` does.

**Fix:** pass `Duration.zero` for no debounce, or a positive duration.

## while loading more items of a PagedList

**When:** the `onLoadMore` of a `PagedList` threw. The text is the `context` of
the report in the console.

**Why:** the list keeps its items, shows a retry row (never the exception) and
reports the error to `FlutterError.onError`.

**Fix:** handle the error in `onLoadMore` if it is expected; the user can retry
from the row.

## while refreshing a PagedList

**When:** the `onRefresh` of a `PagedList` threw. The text is the `context` of
the report in the console.

**Why:** the list keeps its items and the error is reported to
`FlutterError.onError`.

**Fix:** handle the error in `onRefresh` if it is expected.

## PagedList.hasMore is true but onLoadMore is null.

**When:** in a debug build, a `PagedList` has `hasMore: true` and no
`onLoadMore`.

**Why:** nothing can load the next page. A release build shows no "Show more"
button and never loads automatically.

**Fix:** pass `onLoadMore`, or set `hasMore` to false.

```dart
PagedList<Patient>(
  items: patients,
  itemBuilder: (context, patient, index) => PatientTile(patient),
  hasMore: hasMore,
  onLoadMore: loadNextPage,
)
```

## ResponsiveTable.columns must not be empty.

**When:** in a debug build, a `ResponsiveTable` has no columns.

**Why:** there is nothing to show for a row. A release build draws nothing.

**Fix:** pass at least one `TableColumn`.

```dart
ResponsiveTable<Patient>(
  columns: [TableColumn(label: 'Name', value: (p) => p.name)],
  rows: patients,
)
```

## ResponsiveTable.sortColumnIndex is out of range.

**When:** in a debug build, `sortColumnIndex` of a `ResponsiveTable` is below
zero or not under `columns.length`.

**Why:** no column has that index. A release build ignores it and shows the
table unsorted.

**Fix:** pass the index of one of `columns`, or `null` when the rows are
unsorted.

```dart
ResponsiveTable<Patient>(
  columns: columns,
  rows: patients,
  sortColumnIndex: 0, // < columns.length
)
```

## DateField, DateRangeField or TimeField shows English text, or the picker is in English

**When:** the app is in French (or another language) but a `DateField`,
`DateRangeField` or `TimeField` shows English dates or times and the picker's buttons read
"Cancel" and "OK".

**Why:** the date and time text and the pickers come from Flutter's
`MaterialLocalizations`, which the app adds with
`GlobalMaterialLocalizations.delegate` and a `supportedLocales` entry for the
language. `NxgtMaterialLocalizationsDelegate` only supplies this package's own
strings (the clear button, the `datesRangeValue` joiner of a range, and the
`datesBefore` and `datesAfter` range errors of `firstDate` and `lastDate`).

**Fix:** add Flutter's delegates next to this package's, and list the locale.

```dart
MaterialApp(
  localizationsDelegates: const [
    NxgtMaterialLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: NxgtMaterialLocalizations.supportedLocales,
)
```

## length must be 1 to 12

**When:** in a debug build, an `OtpField` is created with `length: 0` or
`length: 13` (or any value outside 1 to 12).

**Why:** the field draws one 48 dp slot per digit and asserts a usable range.
A release build does not check it.

**Fix:** pass a `length` from 1 to 12.

```dart
OtpField(label: 'Code', length: 6) // 1 to 12
```
