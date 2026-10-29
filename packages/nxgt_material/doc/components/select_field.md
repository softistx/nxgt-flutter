# SelectField

Library: `package:nxgt_material/selection.dart`

A single choice in a list, as a `FormField<T?>` that looks like a text field:
a Material 3 `DropdownMenu` for a few options, a searchable sheet for a long
list on a phone.

## When to use it

More than about six options, or little room. For two to six options that
should stay visible use `RadioGroupField`; for a handful of short options
that wrap use `ChoiceChipsField`. `SelectField` is a form field around
Material's `DropdownMenu` (which is not one): `validate`, `save` and `reset`
work in a `Form`.

- **Medium window and up, or 12 options or fewer without `searchable`**: the
  `DropdownMenu` menu. With `searchable` the user types to filter.
- **Compact window (under 600 dp) with `searchable` or more than 12
  options**: tapping the field opens `context.showAdaptiveSheet` titled with
  the label, holding a search box (case- and accent-insensitive) and the
  options as 48 dp tiles; the chosen one is marked. Choosing closes the sheet
  and sets the value; closing it any other way keeps the old value. When
  nothing matches the search, the sheet shows (and announces) "No results" /
  "Aucun résultat" (`fieldsSelectNoResults`). The folding covers common Latin
  accents (é, ç, ñ, ü...), not ligatures such as œ, æ or ß, nor decomposed
  (NFD) accents. In a searchable menu, text typed without choosing an option
  is dropped when the field loses focus.

## Example

```dart
SelectField<String>(
  label: 'Country',
  required: true,
  searchable: true,
  helperText: 'Where you live',
  options: const [
    ChoiceOption(value: 'fr', label: 'France'),
    ChoiceOption(value: 'ci', label: "C\u00f4te d'Ivoire", description: 'West Africa'),
    ChoiceOption(value: 'xx', label: 'Elsewhere', enabled: false),
  ],
  initialValue: 'fr',
  onChanged: (country) => setState(() => _country = country),
)
```

Inside a `Form`, `required` with nothing chosen fails with the localized
`fieldsRequired` string; `validator` runs after it. `autovalidateMode` follows
the `Form` when left `null`. A disabled field is not validated and shows no
error.

Without `required`, a clear button (tooltip "Clear selection" /
"Effacer le choix") returns the value to `null` and calls `onChanged(null)`.
A tap on an option never reports `null`.

## Accessibility

The field is one node: the label, the chosen value, and the error (or the
helper text) as its hint. The error is drawn once, under the field, with the
`alert` role and, outside the web, a live region; the field's own border turns
to the error colour. When a clear button is shown, "Clear selection" is also a
custom semantics action of the field. The field and the clear button are at
least 48 dp on every platform. Enter or Space opens the menu (Enter alone while
`searchable`, since Space types), the arrows move in it, Enter chooses and
Escape closes; the down arrow does not open the closed menu (Flutter's `DropdownMenu` binds it to the highlight). On a compact window, Enter, Space or the down arrow opens the
sheet. Disabled options stay visible and cannot be chosen. The layout fills the
parent's width, mirrors in right-to-left and holds at large text sizes.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The label of the field, also read by screen readers and the title of the sheet. |
| `options` | `List<ChoiceOption<T>>` | The options, in order; values must be unique. |
| `initialValue` | `T?` | Starting choice (one of the options), restored by `Form.reset`. |
| `onChanged` | `ValueChanged<T?>?` | Called at every change; `null` when cleared. |
| `onSaved` | `FormFieldSetter<T?>?` | Called by `FormState.save`. |
| `validator` | `FormFieldValidator<T?>?` | Extra validator, after `required`. |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the `Form`. |
| `required` | `bool` | A choice is needed to be valid; hides the clear button. Default `false`. |
| `searchable` | `bool` | Type to filter the menu, and a sheet on a compact window. Default `false`. |
| `enabled` | `bool` | Whether it accepts input. Default `true`. |
| `focusNode` | `FocusNode?` | Focus node of the field's control. |
| `helperText` | `String?` | A hint under the field, replaced by the error. |

`ChoiceOption<T>` has `value`, `label`, `description` (a second line in the
menu entry and the sheet tile) and `enabled`.
