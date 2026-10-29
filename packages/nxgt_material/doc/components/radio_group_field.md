# RadioGroupField

Library: `package:nxgt_material/selection.dart`

A single choice among a few options, as a `FormField<T?>`, with a visible group
label, helper text and an announced error.

## When to use it

Two to six options the user should see at once. For a long list use a select;
for one lone option without form behaviour use Material's `RadioListTile`.
`RadioGroupField` is built on Flutter's `RadioGroup`, so the arrow keys move
the choice inside the group.

## Example

```dart
RadioGroupField<Plan>(
  label: 'Plan',
  required: true,
  options: const [
    ChoiceOption(value: Plan.monthly, label: 'Monthly', description: 'Billed every month'),
    ChoiceOption(value: Plan.yearly, label: 'Yearly'),
    ChoiceOption(value: Plan.lifetime, label: 'Lifetime', enabled: false),
  ],
  initialValue: Plan.monthly,
  onChanged: (plan) => setState(() => _plan = plan),
)
```

Inside a `Form`, `validate`, `save` and `reset` work as for any field. With
`required`, no choice fails with the localized `fieldsRequired` string ("This
field is required" / "Ce champ est obligatoire"); `validator` runs after it.
`autovalidateMode` follows the `Form` when left `null`. `onChanged` receives
the chosen value; it is never called with `null` by a tap.

## Accessibility

The group is one container node named by its label (the visible title) whose
children are the options; the error, or the helper text, is the container's
hint. Each option is a full-width tile at least 48 dp high on every platform
(also under the compact desktop density), reading its label, description,
checked state and its place in the exclusive group. Tab enters and leaves the
group; Up, Down, Left and Right move the choice and skip disabled options,
Space chooses the focused one. Long labels wrap at large text sizes and the
layout mirrors in right-to-left. The error has the `alert` role and, outside
the web, a live region. A disabled field ignores input and is not validated;
a disabled option stays visible and is skipped.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The group title, visible and read as the group name. |
| `options` | `List<ChoiceOption<T>>` | The options, in order; values must be unique. |
| `initialValue` | `T?` | Starting choice (one of the options), restored by `Form.reset`. |
| `onChanged` | `ValueChanged<T?>?` | Called at every change. |
| `onSaved` | `FormFieldSetter<T?>?` | Called by `FormState.save`. |
| `validator` | `FormFieldValidator<T?>?` | Extra validator, after `required`. |
| `autovalidateMode` | `AutovalidateMode?` | When to validate; `null` follows the `Form`. |
| `required` | `bool` | A choice is needed to be valid. Default `false`. |
| `enabled` | `bool` | Whether it accepts input. Default `true`. |
| `focusNode` | `FocusNode?` | Focus node of the first enabled option; it stays unattached when the field is disabled or every option is. |
| `helperText` | `String?` | A hint under the group, replaced by the error. |

`ChoiceOption<T>` has `value`, `label`, `description` and `enabled`.
