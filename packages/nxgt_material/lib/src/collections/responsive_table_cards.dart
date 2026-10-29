import 'package:flutter/material.dart';
import 'package:nxgt_material/src/collections/table_column.dart';
import 'package:nxgt_material/src/display/description_list.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// The compact layout of a `ResponsiveTable`: one card per row.
class ResponsiveTableCards<T> extends StatelessWidget {
  /// Creates the cards layout.
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
    final sort = onSort;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        if (sort != null && columns.any((c) => c.sortable))
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _sortMenu(context, sort),
          ),
        for (final row in rows) _card(context, row),
      ],
    );
  }

  String _sortedLabel(BuildContext context, int index) {
    final l10n = context.materialL10n;
    final label = columns[index].label;
    if (index != sortColumnIndex) return label;
    return sortAscending
        ? l10n.collectionsSortedAscending(label)
        : l10n.collectionsSortedDescending(label);
  }

  Widget _sortMenu(
    BuildContext context,
    void Function(int, {required bool ascending}) sort,
  ) {
    return PopupMenuButton<int>(
      tooltip: context.materialL10n.collectionsSortBy,
      icon: const Icon(Icons.sort),
      style: targetStyle,
      onSelected: (index) =>
          sort(index, ascending: index != sortColumnIndex || !sortAscending),
      itemBuilder: (context) => [
        for (var i = 0; i < columns.length; i++)
          if (columns[i].sortable)
            PopupMenuItem<int>(
              value: i,
              child: Semantics(
                label: _sortedLabel(context, i),
                excludeSemantics: true,
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(child: Text(columns[i].label)),
                    if (i == sortColumnIndex)
                      Icon(
                        sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 18,
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _card(BuildContext context, T row) {
    final items = [
      for (final column in columns)
        DescriptionItem(label: column.label, value: column.value(row)),
    ];
    final tap = onRowTap;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: DescriptionList(items: items),
    );
    if (tap == null) return Card(margin: EdgeInsets.zero, child: content);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        container: true,
        button: true,
        onTap: () => tap(row),
        label: items.map((i) => '${i.label}, ${i.value}').join('. '),
        excludeSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => tap(row),
            excludeFromSemantics: true,
            child: content,
          ),
        ),
      ),
    );
  }
}
