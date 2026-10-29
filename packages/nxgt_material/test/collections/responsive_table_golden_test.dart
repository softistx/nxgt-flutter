import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/collections.dart';

const _rows = [('Ada Lovelace', '36', 'Paid'), ('Grace Hopper', '85', 'Due')];

final _columns = [
  TableColumn<(String, String, String)>(
    label: 'Name',
    value: (r) => r.$1,
    sortable: true,
  ),
  TableColumn<(String, String, String)>(
    label: 'Age',
    value: (r) => r.$2,
    sortable: true,
    numeric: true,
  ),
  TableColumn<(String, String, String)>(label: 'Status', value: (r) => r.$3),
];

Widget _table(double width, {required bool tappable}) {
  return Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(size: Size(width, 600)),
      child: SizedBox(
        width: width,
        child: ResponsiveTable<(String, String, String)>(
          columns: _columns,
          rows: _rows,
          sortColumnIndex: 1,
          sortAscending: false,
          onSort: (_, {required ascending}) {},
          onRowTap: tappable ? (_) {} : null,
        ),
      ),
    ),
  );
}

Future<void> main() async {
  await goldenTest(
    'ResponsiveTable looks right in light and dark, compact and medium',
    fileName: 'responsive_table',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final brightness in Brightness.values)
          for (final (name, width, tappable) in <(String, double, bool)>[
            ('compact', 360, true),
            ('medium', 640, false),
          ])
            GoldenTestScenario(
              name: '${brightness.name} $name',
              child: Theme(
                data: ThemeData(
                  colorSchemeSeed: Colors.indigo,
                  brightness: brightness,
                ),
                child: _table(width, tappable: tappable),
              ),
            ),
      ],
    ),
  );
}
