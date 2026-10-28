# FormSection

Library: `package:nxgt_material/forms.dart`

A titled group of related form fields.

## When to use it

Inside a long `Form`, one per topic ("Account", "Address"), so the form can be navigated by heading.

## Example

```dart
FormSection(
  title: 'Account',
  description: 'How you sign in.',
  children: [
    EmailField(label: 'Email'),
    PasswordField(label: 'Password'),
  ],
)
```

## Accessibility

- The title is announced as a heading.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `title` | `String` | The heading. |
| `description` | `String?` | A sentence under the heading. |
| `children` | `List<Widget>` | The fields, in a column. |
| `spacing` | `double` | Vertical gap. Default `16`. |
