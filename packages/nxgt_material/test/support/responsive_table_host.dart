import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/collections.dart';
import 'package:nxgt_material/l10n.dart';

typedef SortCall = ({int column, bool ascending});

const tablePeople = [('Ada', '36'), ('Grace', '85')];

final tableColumns = [
  TableColumn<(String, String)>(
    label: 'Name',
    value: (r) => r.$1,
    sortable: true,
  ),
  TableColumn<(String, String)>(
    label: 'Age',
    value: (r) => r.$2,
    numeric: true,
  ),
];

Widget tableHost(
  Widget table, {
  double width = 800,
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      NxgtMaterialLocalizationsDelegate(),
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: NxgtMaterialLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(size: Size(width, 900), textScaler: TextScaler.linear(scale)),
      child: Directionality(textDirection: direction, child: child!),
    ),
    home: Scaffold(body: SingleChildScrollView(child: table)),
  );
}

Future<void> pumpTable(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

ResponsiveTable<(String, String)> buildTable({
  List<(String, String)> rows = tablePeople,
  int? sortColumnIndex,
  bool ascending = true,
  void Function(int, {required bool ascending})? onSort,
  void Function((String, String))? onRowTap,
  Widget? empty,
}) => ResponsiveTable<(String, String)>(
  columns: tableColumns,
  rows: rows,
  sortColumnIndex: sortColumnIndex,
  sortAscending: ascending,
  onSort: onSort,
  onRowTap: onRowTap,
  empty: empty,
);
