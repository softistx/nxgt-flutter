import 'package:flutter/foundation.dart';

/// One column of a `ResponsiveTable`: its [label], how to read its [value]
/// from a row, and whether it sorts or holds a number.
@immutable
class TableColumn<T> {
  /// Creates a TableColumn.
  const new({
    required this.label,
    required this.value,
    this.sortable = false,
    this.numeric = false,
  });

  /// The header, also the label of the cell on a compact card.
  final String label;

  /// The text of this column's cell for a row, already formatted.
  final String Function(T row) value;

  /// Whether the user can sort by this column. It needs the table's `onSort`.
  final bool sortable;

  /// Whether the column holds numbers: its header and cells are aligned to
  /// the end in the table.
  final bool numeric;
}
