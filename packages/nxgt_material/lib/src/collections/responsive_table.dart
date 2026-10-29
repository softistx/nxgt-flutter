import 'package:flutter/material.dart';
import 'package:nxgt_material/src/collections/responsive_table_cards.dart';
import 'package:nxgt_material/src/collections/responsive_table_grid.dart';
import 'package:nxgt_material/src/collections/table_column.dart';
import 'package:nxgt_material/src/feedback/empty_state.dart';
import 'package:nxgt_material/src/layout/window_size.dart';

/// Rows of data as a table from the medium window size up and as one card per
/// row on compact.
///
/// From medium it is a Material 3 `DataTable`, scrolling sideways when it is
/// wider than its space. On compact each row becomes a `Card` built on a
/// `DescriptionList`, the column labels naming the values, with a sort menu
/// beside the cards. Prefer it to a `DataTable` that must also work on a
/// phone. Give it unbounded height (it lives in a scrolling page) or wrap it
/// in a scroll view yourself; for rows that load page by page use `PagedList`.
///
/// **Sorting.** The caller owns the order: it passes [sortColumnIndex] and
/// [sortAscending], sorts [rows] when [onSort] fires and passes them back.
/// Only a [TableColumn.sortable] column sorts, and only with an [onSort].
/// Sortable headers are buttons; the sorted column is read as "Name, sorted
/// ascending" (or descending), and the sort menu of the compact layout says
/// the same.
///
/// **Rows.** With [onRowTap] a row is a button (a whole card on compact);
/// without it rows are not interactive. With no [rows] the [empty] state is
/// shown instead of a header with nothing under it.
class ResponsiveTable<T> extends StatelessWidget {
  /// Creates a ResponsiveTable.
  const new({
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.onRowTap,
    this.empty,
    super.key,
  }) : assert(columns.length > 0, 'ResponsiveTable.columns is empty.'),
       assert(
         sortColumnIndex == null ||
             (sortColumnIndex >= 0 && sortColumnIndex < columns.length),
         'ResponsiveTable.sortColumnIndex is out of range.',
       );

  /// The columns, in order. At least one.
  final List<TableColumn<T>> columns;

  /// The rows, in the order to show them.
  final List<T> rows;

  /// The index in [columns] the rows are sorted by; `null` when unsorted.
  final int? sortColumnIndex;

  /// Whether the sort by [sortColumnIndex] is ascending.
  final bool sortAscending;

  /// Called with the column and the direction the user chose: a sortable header
  /// or a sort menu entry was activated. A column already sorted flips its
  /// direction; another starts ascending.
  final void Function(int columnIndex, {required bool ascending})? onSort;

  /// Called with the row the user tapped; `null` makes rows inert.
  final void Function(T row)? onRowTap;

  /// Shown instead of the default `EmptyState` when [rows] is empty.
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) return const SizedBox.shrink();
    if (rows.isEmpty) return empty ?? const EmptyState();
    final index = sortColumnIndex;
    final valid = index != null && index >= 0 && index < columns.length;
    final sorted = valid ? index : null;
    if (context.windowSize.isAtLeast(WindowSize.medium)) {
      return ResponsiveTableGrid<T>(
        columns: columns,
        rows: rows,
        sortColumnIndex: sorted,
        sortAscending: sortAscending,
        onSort: onSort,
        onRowTap: onRowTap,
      );
    }
    return ResponsiveTableCards<T>(
      columns: columns,
      rows: rows,
      sortColumnIndex: sorted,
      sortAscending: sortAscending,
      onSort: onSort,
      onRowTap: onRowTap,
    );
  }
}
