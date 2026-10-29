import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/collections.dart';
import 'package:nxgt_material/feedback.dart';

import '../support/responsive_table_host.dart';

void main() {
  group('medium and up', () {
    testWidgets('is a DataTable with the cells', (tester) async {
      await pumpTable(tester, tableHost(buildTable()));

      expect(find.byType(DataTable), findsOneWidget);
      expect(find.byType(Card), findsNothing);
      expect(find.text('Grace'), findsOneWidget);
      expect(find.text('36'), findsOneWidget);
    });

    testWidgets('right-aligns the numeric column', (tester) async {
      await pumpTable(tester, tableHost(buildTable()));

      final table = tester.widget<DataTable>(find.byType(DataTable));
      expect(table.columns.map((c) => c.numeric), [false, true]);
    });

    testWidgets('lands numeric cells flush with the end of their column', (
      tester,
    ) async {
      await pumpTable(
        tester,
        tableHost(buildTable(rows: const [('Ada', '5'), ('Grace', '1000')])),
      );

      final right = tester.getTopRight(find.text('1000')).dx;
      expect(tester.getTopRight(find.text('5')).dx, right);
      expect(tester.getTopRight(find.text('Age')).dx, right);
      expect(
        tester.getTopLeft(find.text('Ada')).dx,
        tester.getTopLeft(find.text('Grace')).dx,
      );
    });

    testWidgets('fills the available width', (tester) async {
      await pumpTable(
        tester,
        tableHost(
          ResponsiveTable<(String, String, String)>(
            columns: [
              for (final label in ['A', 'B', 'C'])
                TableColumn(label: label, value: (r) => r.$1),
            ],
            rows: const [('x', 'y', 'z')],
          ),
        ),
      );

      expect(tester.getSize(find.byType(DataTable)).width, closeTo(800, 0.01));
    });

    testWidgets('draws a column cell builder instead of the text', (
      tester,
    ) async {
      await pumpTable(
        tester,
        tableHost(
          ResponsiveTable<(String, String)>(
            columns: [
              TableColumn<(String, String)>(
                label: 'Name',
                value: (r) => r.$1,
                cell: (context, r) => Chip(label: Text('chip ${r.$1}')),
              ),
              TableColumn<(String, String)>(label: 'Age', value: (r) => r.$2),
            ],
            rows: tablePeople,
          ),
        ),
      );

      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.text('chip Ada'), findsOneWidget);
      expect(find.text('Ada'), findsNothing);
      expect(find.text('36'), findsOneWidget);
    });

    testWidgets('a sortable header sorts and flips the direction', (
      tester,
    ) async {
      final calls = <SortCall>[];
      await pumpTable(
        tester,
        tableHost(
          buildTable(
            sortColumnIndex: 0,
            onSort: (c, {required ascending}) =>
                calls.add((column: c, ascending: ascending)),
          ),
        ),
      );

      await tester.tap(find.text('Name'));
      expect(calls.single, (column: 0, ascending: false));
    });

    testWidgets('an unsortable header does nothing', (tester) async {
      final calls = <SortCall>[];
      await pumpTable(
        tester,
        tableHost(
          buildTable(
            onSort: (c, {required ascending}) =>
                calls.add((column: c, ascending: ascending)),
          ),
        ),
      );

      await tester.tap(find.text('Age'));
      expect(calls, isEmpty);
    });

    testWidgets('a tap on a row reports it', (tester) async {
      (String, String)? tapped;
      await pumpTable(
        tester,
        tableHost(buildTable(onRowTap: (r) => tapped = r)),
      );

      await tester.tap(find.text('Grace'));
      expect(tapped, ('Grace', '85'));
    });

    testWidgets('announces the sorted column and direction', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTable(
        tester,
        tableHost(
          buildTable(sortColumnIndex: 0, onSort: (_, {required ascending}) {}),
        ),
      );
      expect(find.bySemanticsLabel('Name, sorted ascending'), findsOneWidget);

      await pumpTable(
        tester,
        tableHost(
          buildTable(
            sortColumnIndex: 0,
            ascending: false,
            onSort: (_, {required ascending}) {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Name, sorted descending'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a sortable header is a button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTable(
        tester,
        tableHost(buildTable(onSort: (_, {required ascending}) {})),
      );

      final header = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(InkWell),
      );
      final data = tester.getSemantics(header).getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('shows the empty state with no rows', (tester) async {
      await pumpTable(tester, tableHost(buildTable(rows: const [])));

      expect(find.byType(DataTable), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('shows a custom empty widget', (tester) async {
      await pumpTable(
        tester,
        tableHost(buildTable(rows: const [], empty: const Text('No people'))),
      );

      expect(find.text('No people'), findsOneWidget);
    });

    testWidgets('lays out from the right in RTL', (tester) async {
      await pumpTable(
        tester,
        tableHost(buildTable(), direction: TextDirection.rtl),
      );

      expect(
        Directionality.of(tester.element(find.byType(DataTable))),
        TextDirection.rtl,
      );
      expect(
        tester.getTopRight(find.text('Name')).dx,
        greaterThan(tester.getTopRight(find.text('Age')).dx),
      );
      expect(tester.getTopRight(find.text('Name')).dx, greaterThan(400));
      expect(tester.getTopLeft(find.text('Age')).dx, lessThan(400));
    });

    testWidgets('survives text scale 2', (tester) async {
      await pumpTable(tester, tableHost(buildTable(), width: 600, scale: 2));

      expect(tester.takeException(), isNull);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Ada'), findsOneWidget);
      expect(tester.getSize(find.text('Name')).height, greaterThan(30));
    });

    testWidgets('survives IntrinsicHeight', (tester) async {
      await pumpTable(tester, tableHost(IntrinsicHeight(child: buildTable())));

      expect(tester.takeException(), isNull);
    });
  });

  group('misuse', () {
    // The release fallbacks (no columns draws nothing, an out-of-range sort
    // index shows the table unsorted) sit behind the asserts, which stop a
    // debug run before build: tests cannot reach them.
    test('asserts on no columns', () {
      expect(
        () => ResponsiveTable<int>(columns: const [], rows: const []),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'ResponsiveTable.columns is empty.',
          ),
        ),
      );
    });

    test('asserts on a sort column out of range', () {
      expect(
        () => ResponsiveTable<(String, String)>(
          columns: tableColumns,
          rows: tablePeople,
          sortColumnIndex: 2,
        ),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'ResponsiveTable.sortColumnIndex is out of range.',
          ),
        ),
      );
    });
  });
}
