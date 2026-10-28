import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('the back gesture on the list really pops the route', (
    tester,
  ) async {
    var back = 0;
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(themedHost(const SizedBox()));
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(body: _layout(onBack: () => back++)),
          ),
        );
    await tester.pumpAndSettle();
    expect(find.byType(ListDetailLayout), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ListDetailLayout), findsNothing);
    expect(back, 0);
  });

  testWidgets('both panes keep their state across 648 dp, hidden or not', (
    tester,
  ) async {
    _Probe.mounts = 0;
    Widget probe(double width, {required bool showDetail}) => Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        child: ListDetailLayout(
          showDetail: showDetail,
          list: const _Probe(),
          detail: const _Probe(),
        ),
      ),
    );
    await _pump(tester, 1000, probe(900, showDetail: true));
    expect(_Probe.mounts, 2);
    for (final (width, detail) in [
      (500.0, true),
      (500.0, false),
      (649.0, false),
      (648.0, true),
      (900.0, true),
    ]) {
      await tester.pumpWidget(themedHost(probe(width, showDetail: detail)));
      await tester.pump();
    }
    expect(_Probe.mounts, 2);
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

  group('the hidden pane', () {
    Widget fields() => ListDetailLayout(
      showDetail: false,
      list: const TextField(key: Key('list-field')),
      detail: const Column(
        children: [
          Text('Hidden detail'),
          TextField(key: Key('detail-field')),
        ],
      ),
    );

    testWidgets('has no semantics nodes', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, 400, fields());
      expect(find.bySemanticsLabel('Hidden detail'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(ListDetailLayout),
          matching: find.text('Hidden detail', skipOffstage: false),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('is skipped by Tab traversal', (tester) async {
      await _pump(tester, 400, fields());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(
        find.descendant(
          of: find.byKey(const Key('list-field')),
          matching: find.byElementPredicate((e) => e == focused),
        ),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final next = FocusManager.instance.primaryFocus?.context;
      final inDetail =
          next != null &&
          find
              .descendant(
                of: find.byKey(const Key('detail-field'), skipOffstage: false),
                matching: find.byElementPredicate(
                  (e) => e == next,
                  skipOffstage: false,
                ),
                skipOffstage: false,
              )
              .evaluate()
              .isNotEmpty;
      expect(inDetail, isFalse);
    });
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

class _Probe extends StatefulWidget {
  const new();

  static int mounts = 0;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    _Probe.mounts++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 10);
}
