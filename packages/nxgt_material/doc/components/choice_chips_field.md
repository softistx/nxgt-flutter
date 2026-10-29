# ChoiceChipsField and FilterChipsField

Library: `package:nxgt_material/selection.dart`

A choice among a few short options shown as chips that wrap onto several
lines, as a `FormField`, with a visible group label, helper text and an
announced error. `ChoiceChipsField<T>` chooses one option (Material 3
`ChoiceChip`, value `T?`); `FilterChipsField<T>` chooses several (Material 3
`FilterChip`, value `Set<T>`).

## When to use it

Two to about eight short labels (a size, a category, a set of tags) that the
user should see at once. Two classes rather than a `multiple` flag keep the
value type sound: a flag would force a `dynamic` value or a `Set` of one. For
long labels or descriptions use `RadioGroupField` or `CheckboxGroupField`; for
a long list use a select.

## Example

```dart
ChoiceChipsField<Size>(
  label: 'Size',
  required: true,
  options: const [
    ChoiceOption(value: Size.s, label: 'Small'),
    ChoiceOption(value: Size.m, label: 'Medium', description: 'Most popular'),
    ChoiceOption(value: Size.l, label: 'Large', enabled: false),
  ],
  initialValue: Size.m,
  onChanged: (size) => setState(() => _size = size),
)

FilterChipsField<Topic>(
  label: 'Topics',
  options: const [
    ChoiceOption(value: Topic.news, label: 'News'),
    ChoiceOption(value: Topic.sport, label: 'Sport'),
  ],
  initialValue: const {Topic.news},
  onChanged: (topics) => setState(() => _topics = topics),
)
```

Inside a `Form`, `validate`, `save` and `reset` work as for any field. With
`required`, nothing chosen fails with the localized `fieldsRequired` string
("This field is required" / "Ce champ est obligatoire"); `validator` runs
after it. `autovalidateMode` follows the `Form` when left `null`.

- **Single choice.** Tapping the chosen chip again clears the choice
  (`onChanged(null)`) unless the field is `required`, where it keeps it, so a
  required field never goes back to empty by a tap.
- **Multiple choice.** Each change reports a new unmodifiable `Set` in the
  order of the options; `initialValue` is left untouched.
- **Description.** `ChoiceOption.description` is the chip's tooltip (long press
  or hover) and part of what a screen reader reads; it is never visible text.

## Accessibility

The group is one container node named by its label (the visible title) whose
children are the chips; the error, or the helper text, is the container's hint.
Each chip is a button reading its label and `selected` state; in a
`ChoiceChipsField` it is also marked as part of an exclusive group (radio-like),
in a `FilterChipsField` it is not (checkbox-like). Chips are padded to at least
48 dp on every platform, also under the compact desktop density. Tab moves
between chips and skips disabled ones; Space and Enter toggle the focused chip.
Chips wrap onto new lines at large text sizes and the layout mirrors in
right-to-left. The error has the `alert` role and, outside the web, a live
region. A disabled field ignores input and is not validated; a disabled option
stays visible and is skipped.

## Properties

Both classes take the same properties; the value type differs.

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The group title, visible and read as the group name. |
| `options` | `List<ChoiceOption<T>>` | The options, in order; values must be unique. |
| `initialValue` | `T?` / `Set<T>` | Starting choice (values of the options), restored by `Form.reset`. |
| `onChanged` | `ValueChanged<T?>?` / `ValueChanged<Set<T>>?` | Called at every change. |
| `onSaved` | `FormFieldSetter<T?>?` / `FormFieldSetter<Set<T>>?` | Called by `FormState.save`. |
| `validator` | `FormFieldValidator<T?>?` / `FormFieldValidator<Set<T>>?` | Extra validator, after `required`. |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the `Form`. |
| `required` | `bool` | A choice is needed to be valid. Default `false`. |
| `enabled` | `bool` | Whether it accepts input. Default `true`. |
| `focusNode` | `FocusNode?` | Focus node of the first enabled chip; it stays unattached when the field is disabled or every option is. |
| `helperText` | `String?` | A hint under the group, replaced by the error. |

`ChoiceOption<T>` has `value`, `label`, `description` and `enabled`.
