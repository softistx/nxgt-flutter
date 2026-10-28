import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import '../support/host.dart';

Widget _layout({bool showDetail = false, VoidCallback? onBack}) =>
    ListDetailLayout(
      showDetail: showDetail,
      onBack: onBack,
      list: const Text('The list'),
      detail: const Text('The detail'),
    );

Future<void> _pump(WidgetTester tester, double width, Widget layout) async {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpApp(themedHost(layout));
}

void main() {
  testWidgets('shows both panes above 648 dp', (tester) async {
    await _pump(tester, 649, _layout());
    expect(find.text('The list'), findsOneWidget);
    expect(find.text('The detail'), findsOneWidget);
  });

  testWidgets('lists at 360 dp and details fill the rest', (tester) async {
    await _pump(tester, 900, _layout());
    expect(tester.getRect(find.byType(SizedBox).first).width, 360);
    expect(
      tester.getTopLeft(find.text('The detail')).dx,
      greaterThanOrEqualTo(360),
    );
  });

  testWidgets('shows only the list at 648 dp until a detail is picked', (
    tester,
  ) async {
    await _pump(tester, 648, _layout());
    expect(find.text('The list'), findsOneWidget);
    expect(find.text('The detail'), findsNothing);
  });

  testWidgets('shows only the detail on a narrow layout when asked', (
    tester,
  ) async {
    await _pump(tester, 400, _layout(showDetail: true));
    expect(find.text('The list'), findsNothing);
    expect(find.text('The detail'), findsOneWidget);
  });

  testWidgets('follows its own width, not the window', (tester) async {
    await _pump(
      tester,
      1200,
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 500, child: _layout()),
      ),
    );
    expect(find.text('The detail'), findsNothing);
  });

  testWidgets('the back gesture on a narrow detail calls onBack', (
    tester,
  ) async {
    var back = 0;
    await _pump(tester, 400, _layout(showDetail: true, onBack: () => back++));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(back, 1);
  });

  testWidgets('the back gesture on the list leaves the route', (tester) async {
    var back = 0;
    await _pump(tester, 400, _layout(onBack: () => back++));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(back, 0);
  });

  testWidgets('the detail pane has a rounded surface (plain theme too)', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(900, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(themedHost(_layout(), plainTheme: true));
    final material = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('The detail'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.borderRadius, isNotNull);
  });

  group('semantics', () {
    testWidgets('each pane is its own container', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, 900, _layout());
      expect(
        tester.getSemantics(find.text('The list')),
        isSemantics(label: 'The list'),
      );
      expect(
        tester.getSemantics(find.text('The detail')),
        isSemantics(label: 'The detail'),
      );
      handle.dispose();
    });

    testWidgets('a button in the list keeps its role and 48 dp', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        900,
        ListDetailLayout(
          showDetail: false,
          list: FilledButton(onPressed: () {}, child: const Text('Open')),
          detail: const Text('The detail'),
        ),
      );
      expect(
        tester.getSemantics(find.text('Open')),
        isSemantics(label: 'Open', isButton: true),
      );
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });
}
