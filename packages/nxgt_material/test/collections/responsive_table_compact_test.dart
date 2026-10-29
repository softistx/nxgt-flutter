import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/feedback.dart';

import '../support/responsive_table_host.dart';

void main() {
  group('compact', () {
    testWidgets('is one card per row', (tester) async {
      await pumpTable(tester, tableHost(buildTable(), width: 400));

      expect(find.byType(DataTable), findsNothing);
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.byType(DescriptionList), findsNWidgets(2));
      expect(find.text('Name'), findsNWidgets(2));
      expect(find.text('Ada'), findsOneWidget);
    });

    testWidgets('shows no sort menu without a sortable column and onSort', (
      tester,
    ) async {
      await pumpTable(tester, tableHost(buildTable(), width: 400));

      expect(find.byType(PopupMenuButton<int>), findsNothing);
    });

    testWidgets('the sort menu lists sortable columns only', (tester) async {
      final calls = <SortCall>[];
      await pumpTable(
        tester,
        tableHost(
          buildTable(
            onSort: (c, {required ascending}) =>
                calls.add((column: c, ascending: ascending)),
          ),
          width: 400,
        ),
      );

      await tester.tap(find.byTooltip('Sort by'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(PopupMenuItem<int>),
          matching: find.text('Name'),
        ),
      );
      await tester.pumpAndSettle();

      expect(calls.single, (column: 0, ascending: true));
    });

    testWidgets('choosing the sorted column flips the direction', (
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
          width: 400,
        ),
      );

      await tester.tap(find.byTooltip('Sort by'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(PopupMenuItem<int>),
          matching: find.text('Name'),
        ),
      );
      await tester.pumpAndSettle();

      expect(calls.single, (column: 0, ascending: false));
    });

    testWidgets('the sort menu announces the sorted column', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTable(
        tester,
        tableHost(
          buildTable(
            sortColumnIndex: 0,
            ascending: false,
            onSort: (_, {required ascending}) {},
          ),
          width: 400,
        ),
      );

      await tester.tap(find.byTooltip('Sort by'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Name, sorted descending'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a tap on a card reports its row', (tester) async {
      (String, String)? tapped;
      await pumpTable(
        tester,
        tableHost(buildTable(onRowTap: (r) => tapped = r), width: 400),
      );

      await tester.tap(find.text('Grace'));
      expect(tapped, ('Grace', '85'));
    });

    testWidgets('a tappable card is one button naming its values', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpTable(
        tester,
        tableHost(buildTable(onRowTap: (_) {}), width: 400),
      );

      final node = tester.getSemantics(
        find.bySemanticsLabel('Name, Ada. Age, 36'),
      );
      expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
      handle.dispose();
    });

    testWidgets('cards without onRowTap are not buttons', (tester) async {
      await pumpTable(tester, tableHost(buildTable(), width: 400));

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('shows the empty state with no rows', (tester) async {
      await pumpTable(
        tester,
        tableHost(buildTable(rows: const []), width: 400),
      );

      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('stacks start-aligned in RTL', (tester) async {
      await pumpTable(
        tester,
        tableHost(buildTable(), width: 400, direction: TextDirection.rtl),
      );

      expect(
        Directionality.of(tester.element(find.byType(Card).first)),
        TextDirection.rtl,
      );
      expect(tester.getTopRight(find.text('Ada')).dx, greaterThan(200));
    });

    testWidgets('survives text scale 2', (tester) async {
      await pumpTable(tester, tableHost(buildTable(), width: 400, scale: 2));

      expect(tester.takeException(), isNull);
      expect(find.text('Grace'), findsOneWidget);
    });

    testWidgets('survives IntrinsicHeight', (tester) async {
      await pumpTable(
        tester,
        tableHost(
          IntrinsicHeight(
            child: buildTable(onSort: (_, {required ascending}) {}),
          ),
          width: 400,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the sort button at 48 dp', (tester) async {
      await pumpTable(
        tester,
        tableHost(buildTable(onSort: (_, {required ascending}) {}), width: 400),
      );

      final size = tester.getSize(find.byTooltip('Sort by'));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
