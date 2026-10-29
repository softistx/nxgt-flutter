import 'package:flutter/material.dart';
import 'package:nxgt_material/src/collections/table_column.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// The medium-and-up layout of a `ResponsiveTable`: a `DataTable`.
class ResponsiveTableGrid<T> extends StatelessWidget {
  /// Creates the grid layout.
  const new({
    required this.columns,
    required this.rows,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onRowTap,
    super.key,
  });

  /// The columns.
  final List<TableColumn<T>> columns;

  /// The rows.
  final List<T> rows;

  /// The sorted column, already checked against [columns].
  final int? sortColumnIndex;

  /// The direction of the sort.
  final bool sortAscending;

  /// Reports a sort request.
  final void Function(int columnIndex, {required bool ascending})? onSort;

  /// Reports a tapped row.
  final void Function(T row)? onRowTap;

  @override
  Widget build(BuildContext context) {
    final tap = onRowTap;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        showCheckboxColumn: false,
        columns: [for (var i = 0; i < columns.length; i++) _column(context, i)],
        rows: [
          for (final row in rows)
            DataRow(
              onSelectChanged: tap == null ? null : (_) => tap(row),
              cells: [
                for (final column in columns)
                  DataCell(
                    column.cell?.call(context, row) ?? Text(column.value(row)),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  DataColumn _column(BuildContext context, int index) {
    final column = columns[index];
    final sort = onSort;
    final l10n = context.materialL10n;
    final label = Text(column.label);
    final sortable = column.sortable && sort != null;
    final sorted = index == sortColumnIndex;
    return DataColumn(
      numeric: column.numeric,
      onSort: sortable ? (i, ascending) => sort(i, ascending: ascending) : null,
      label: !sortable && !sorted
          ? label
          : Semantics(
              button: sortable,
              label: !sorted
                  ? null
                  : sortAscending
                  ? l10n.collectionsSortedAscending(column.label)
                  : l10n.collectionsSortedDescending(column.label),
              excludeSemantics: sorted,
              child: label,
            ),
    );
  }
}
