# DescriptionList

Library: `package:nxgt_material/display.dart`

Labels and values as rows: side by side from the medium window size (600 dp),
stacked on compact.

## When to use it

The details of one record: an invoice, a user, an order. With
`copyable: true` a [CopyButton](copy_button.md) follows the value. For many
rows and columns use `DataTable`; for a tappable row use `ListTile`; for a key
figure use [StatCard](stat_card.md).

## Example

```dart
DescriptionList(
  items: [
    DescriptionItem(label: 'Invoice', value: 'INV-2026-0042', copyable: true),
    DescriptionItem(label: 'Customer', value: 'Ada Lovelace'),
  ],
)
```

`value` is a string you format (number, date, currency, locale). An empty list
draws nothing.

## Layout

Below 600 dp (`WindowSize.compact`) each row is the label over the value. From
600 dp the label sits in a 176 dp column and the value fills the rest. The
choice follows `context.windowSize`, so it tracks the window, not the parent.

## Accessibility

Each row is one node read as "label, value" ("Invoice, INV-2026-0042"), rows
in the order of `items`. Labels are not headings. A copyable row also has its
own button, labelled with the item ("Copy Invoice", "Copier « Invoice »" in
French; the string `actionsCopyItem`, rewordable through
`NxgtMaterialLocalizationsWrapper`). Alignment and spacing follow the text
direction.

## Properties

`DescriptionList`:

| Name | Type | Description |
| --- | --- | --- |
| `items` | `List<DescriptionItem>` | The rows, in reading order. |

`DescriptionItem`:

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | What the row describes. |
| `value` | `String` | The value, already formatted. |
| `copyable` | `bool` | Adds a `CopyButton` for the value (default `false`). |
