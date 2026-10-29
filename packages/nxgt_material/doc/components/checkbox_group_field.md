# CheckboxGroupField

Library: `package:nxgt_material/selection.dart`

Several choices among a few options, as a `FormField<Set<T>>`, with a visible
group label, helper text and an announced error.

## When to use it

A handful of independent options (notification channels, days, topics). For a
single box use `CheckboxField`; for a long list use a multi-select.

## Example

```dart
CheckboxGroupField<Channel>(
  label: 'Notify me by',
  required: true,
  options: const [
    ChoiceOption(value: Channel.email, label: 'Email'),
    ChoiceOption(value: Channel.sms, label: 'SMS', description: 'Rates may apply'),
    ChoiceOption(value: Channel.push, label: 'Push', enabled: false),
  ],
  initialValue: const {Channel.email},
  onChanged: (channels) => setState(() => _channels = channels),
)
```

The value is a `Set<T>` that is never mutated: each change reports a new
unmodifiable set, and `initialValue` is left untouched. With `required`, an
empty set fails with the localized `fieldsRequired` string; `validator` runs
after it and can bound the count itself. `Form.reset` restores `initialValue`.

## Accessibility

The group is one container node named by its label (the visible title) whose
children are one checkbox node per option; the error, or the helper text, is
the container's hint. Each option is a full-width tile at least 48 dp high on
every platform, with label, optional description and checked state. Tab moves
from one option to the next. Long labels wrap at large text sizes and the
layout mirrors in right-to-left. The error has the `alert` role and, outside
the web, a live region; the boxes are drawn in the error colour. A disabled
field ignores input and is not validated; a disabled option stays visible.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The group title, visible and read as the group name. |
| `options` | `List<ChoiceOption<T>>` | The options, in order; values must be unique. |
| `initialValue` | `Set<T>` | Starting choices (all among the options). Default `{}`. |
| `onChanged` | `ValueChanged<Set<T>>?` | Called at every change with a new unmodifiable set. |
| `onSaved` | `FormFieldSetter<Set<T>>?` | Called by `FormState.save`. |
| `validator` | `FormFieldValidator<Set<T>>?` | Extra validator, after `required`. |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the `Form`. |
| `required` | `bool` | At least one choice is needed. Default `false`. |
| `enabled` | `bool` | Whether it accepts input. Default `true`. |
| `focusNode` | `FocusNode?` | Focus node of the first enabled option. |
| `helperText` | `String?` | A hint under the group, replaced by the error. |

`ChoiceOption<T>` has `value`, `label`, `description` and `enabled`.
