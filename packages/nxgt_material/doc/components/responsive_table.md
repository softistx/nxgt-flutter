# ResponsiveTable

Library: `package:nxgt_material/collections.dart`

Rows of data as a Material 3 `DataTable` from the medium window size up, and
as one card per row on compact.

## When to use it

For a list of records with several fields that must work on a phone and on a
desktop: invoices, patients, orders. Prefer it to a `DataTable` alone (it
overflows on a phone) and to a `ListView` of cards you build by hand. For rows
that load page by page use `PagedList`; for the details of one record use
`DescriptionList`.

- Medium window (600 dp) and up: a `DataTable` that scrolls sideways when it
  is wider than its space. Compact: a `Card` per row built on a
  `DescriptionList`, each `TableColumn.label` naming its value, with a sort
  menu above the cards when a column sorts.
- The caller owns the order. Pass `sortColumnIndex` and `sortAscending`, sort
  `rows` when `onSort` fires, and pass them back. A column sorts when its
  `sortable` is true and `onSort` is set. Choosing the sorted column flips its
  direction; another column starts ascending.
- With `onRowTap` a row (a whole card on compact) is a button; without it rows
  are inert.
- With no `rows` the `empty` widget (default `EmptyState`) replaces the table.
- It does not scroll vertically: put it in a page that scrolls.

## Example

```dart
ResponsiveTable<Invoice>(
  columns: [
    TableColumn(label: 'Number', value: (i) => i.number, sortable: true),
    TableColumn(label: 'Client', value: (i) => i.client),
    TableColumn(
      label: 'Amount',
      value: (i) => formatMoney(i.amount),
      sortable: true,
      numeric: true,
    ),
  ],
  rows: invoices,
  sortColumnIndex: sortColumn,
  sortAscending: ascending,
  onSort: (column, {required ascending}) => setState(() {
    sortColumn = column;
    this.ascending = ascending;
    invoices = sortInvoices(invoices, column, ascending);
  }),
  onRowTap: (invoice) => context.push('/invoices/${invoice.id}'),
)
```

## Accessibility

- Sortable headers are buttons (`DataTable` headers). The sorted column is read
  as "Name, sorted ascending" or "Name, sorted descending"
  (`collectionsSortedAscending`, `collectionsSortedDescending`), by its
  header in the table and by its entry in the compact sort menu.
- The compact sort button is named "Sort by" / "Trier par"
  (`collectionsSortBy`) and is at least 48 dp under any density.
- A tappable compact card is one button reading "Label, value" for each
  column; a card with no `onRowTap` reads like a `DescriptionList`.
- The layout mirrors in right-to-left, holds at text scale 2 (the table
  scrolls sideways, the cards grow) and inside an `IntrinsicHeight`. The
  window size comes from `MediaQuery`, not a `LayoutBuilder`.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `columns` | `List<TableColumn<T>>` | The columns, in order; at least one. |
| `rows` | `List<T>` | The rows, in the order to show them. |
| `sortColumnIndex` | `int?` | The index in `columns` the rows are sorted by. |
| `sortAscending` | `bool` | Whether that sort is ascending; default `true`. |
| `onSort` | `void Function(int, {required bool ascending})?` | Called with the column and direction the user chose. |
| `onRowTap` | `void Function(T)?` | Called with the tapped row; `null` makes rows inert. |
| `empty` | `Widget?` | Shown instead of the default `EmptyState` when `rows` is empty. |

`TableColumn<T>`:

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | The header, and the label of the value on a compact card. |
| `value` | `String Function(T)` | The text of the cell for a row, already formatted. |
| `sortable` | `bool` | Whether the user can sort by it; default `false`. |
| `numeric` | `bool` | Whether it holds numbers, aligned to the end in the table; default `false`. |
