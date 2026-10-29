import 'package:flutter/widgets.dart';

/// One column of a `ResponsiveTable`: its [label], how to read its [value]
/// from a row, and whether it sorts or holds a number.
@immutable
class TableColumn<T> {
  /// Creates a TableColumn.
  const new({
    required this.label,
    required this.value,
    this.cell,
    this.sortable = false,
    this.numeric = false,
  });

  /// The header, also the label of the cell on a compact card.
  final String label;

  /// The text of this column's cell for a row, already formatted.
  final String Function(T row) value;

  /// Builds the cell in the table when plain [value] text is not enough (a
  /// status chip, an icon). It is used from the medium window size up; a
  /// compact card shows [value], since a `DescriptionItem` holds text. Keep
  /// [value] meaningful: the compact card and screen readers use it.
  final Widget Function(BuildContext context, T row)? cell;

  /// Whether the user can sort by this column. It needs the table's `onSort`.
  final bool sortable;

  /// Whether the column holds numbers: its header and cells are aligned to
  /// the end in the table.
  final bool numeric;
}
