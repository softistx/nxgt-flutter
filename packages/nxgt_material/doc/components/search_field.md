# SearchField

Library: `package:nxgt_material/collections.dart`

A search input that reports its text once typing pauses: a search icon, a
localized hint, a clear button and the `search` keyboard action.

## When to use it

To filter a list, a table or a select's options, or to query a server as the
user types. It is not a `FormField` (no `validate`, `save` or `reset`): for a
text value in a `Form` use a `TextFormField` or one of the fields. It only
emits text; filtering, including accent- and case-insensitive matching, is
the app's. `SelectField`'s sheet has its own search box for that case.

- `onChanged` fires `debounce` (300 ms by default) after the last keystroke,
  once per pause. `Duration.zero` emits at every keystroke.
- The clear button shows only when there is text. It emits `onChanged('')` at
  once (no debounce), cancels a pending emission and keeps the focus in the
  field. A disabled field has none.
- The keyboard action is `search`. `onSubmitted` fires at once with the text
  and drops a pending `onChanged`.
- No callback fires after the field is disposed.
- Without a `controller` the field owns one (starting at `initialValue`) and a
  focus node, and disposes them; a controller or focus node you pass is never
  disposed. A swapped controller is followed. Swapping the controller drops a pending emission and does not emit. Changing the text of a
  controller from code does not call `onChanged`.

## Example

```dart
SearchField(
  hintText: 'Search patients',
  autofocus: true,
  onChanged: (text) => setState(() => _query = text),
  onSubmitted: (text) => _openFirstMatch(text),
)
```

## Accessibility

One text-field node of the search input type, labelled by the hint ("Search" /
"Rechercher", `collectionsSearchHint`, unless `hintText` is given) while empty. The search icon is
decorative. The clear button is named "Clear search" / "Effacer la recherche"
(its tooltip, `collectionsSearchClear`) and is at least 48 dp on every
platform, as is the field. The layout mirrors in right-to-left, holds at large
text sizes and inside an `IntrinsicHeight`.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `onChanged` | `ValueChanged<String>` | Called with the text after `debounce`, and with `''` at once on clear. |
| `debounce` | `Duration` | The pause before `onChanged`; default 300 ms; zero emits at every edit. |
| `controller` | `TextEditingController?` | Controls the text; never disposed by the field. |
| `initialValue` | `String?` | Starting text when no `controller` is given. |
| `hintText` | `String?` | The placeholder and label; defaults to the localized "Search". |
| `onSubmitted` | `ValueChanged<String>?` | Called at once on the keyboard action. |
| `autofocus` | `bool` | Take the focus when first built. |
| `focusNode` | `FocusNode?` | The focus node; never disposed by the field. |
| `enabled` | `bool` | Whether input is accepted; default `true`. |
