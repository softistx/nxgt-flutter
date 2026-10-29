import 'package:flutter/material.dart';
import 'package:nxgt_material/collections.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

typedef _Patient = ({String name, int age, String ward});

const _patients = <_Patient>[
  (name: 'Ada Lovelace', age: 36, ward: 'Cardiology'),
  (name: 'Grace Hopper', age: 85, ward: 'Neurology'),
  (name: 'Alan Turing', age: 41, ward: 'Oncology'),
];

@widgetbook.UseCase(
  name: 'Default',
  type: ResponsiveTable,
  path: '[Collections]',
)
/// The default use-case of [ResponsiveTable].
Widget buildResponsiveTableDefault(BuildContext context) {
  return _Sortable(
    tappable: context.knobs.boolean(label: 'Rows tappable', initialValue: true),
    empty: context.knobs.boolean(label: 'No rows'),
  );
}

class _Sortable extends StatefulWidget {
  const new({required this.tappable, required this.empty});

  final bool tappable;
  final bool empty;

  @override
  State<_Sortable> createState() => _SortableState();
}

class _SortableState extends State<_Sortable> {
  int _column = 0;
  bool _ascending = true;

  List<_Patient> get _sorted {
    final rows = [..._patients]
      ..sort(
        (a, b) => switch (_column) {
          1 => a.age.compareTo(b.age),
          _ => a.name.compareTo(b.name),
        },
      );
    return _ascending ? rows : rows.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ResponsiveTable<_Patient>(
        columns: [
          TableColumn(label: 'Name', value: (p) => p.name, sortable: true),
          TableColumn(
            label: 'Age',
            value: (p) => '${p.age}',
            sortable: true,
            numeric: true,
          ),
          TableColumn(
            label: 'Ward',
            value: (p) => p.ward,
            cell: (context, p) => Chip(label: Text(p.ward)),
          ),
        ],
        rows: widget.empty ? const [] : _sorted,
        sortColumnIndex: _column,
        sortAscending: _ascending,
        onSort: (column, {required ascending}) => setState(() {
          _column = column;
          _ascending = ascending;
        }),
        onRowTap: widget.tappable ? (p) => debugPrint('tap: ${p.name}') : null,
      ),
    );
  }
}
