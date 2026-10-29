import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import '../../support/host.dart';
import 'adaptive_shell_harness.dart';

class _Counter extends StatefulWidget {
  const new();

  static int mounts = 0;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  void initState() {
    super.initState();
    _Counter.mounts++;
  }

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => taps++),
    child: Text('taps $taps'),
  );
}

Widget statefulShell({
  CompactNavigation compact = CompactNavigation.bar,
  Widget? title,
}) => AdaptiveShell(
  destinations: shellPlaces,
  selectedIndex: 0,
  onSelected: (_) {},
  compactNavigation: compact,
  title: title,
  body: const Align(alignment: Alignment.topLeft, child: _Counter()),
);

void main() {
  group('stability', () {
    testWidgets('the body keeps its state across every size class', (
      tester,
    ) async {
      _Counter.mounts = 0;
      await pumpShell(tester, 400, statefulShell());
      await tester.tap(find.text('taps 0'));
      await tester.pump();
      for (final width in [
        599.0,
        600.0,
        700.0,
        839.0,
        840.0,
        1000.0,
        1700.0,
        700.0,
        400.0,
      ]) {
        tester.view.physicalSize = Size(width, 800);
        await tester.pump();
        expect(find.text('taps 1'), findsOneWidget, reason: '$width');
      }
      expect(_Counter.mounts, 1);
    });

    testWidgets('the body keeps its state with a drawer and a title', (
      tester,
    ) async {
      _Counter.mounts = 0;
      await pumpShell(
        tester,
        400,
        statefulShell(
          compact: CompactNavigation.drawer,
          title: const Text('Acme'),
        ),
      );
      tester.view.physicalSize = const Size(1000, 800);
      await tester.pump();
      tester.view.physicalSize = const Size(400, 800);
      await tester.pump();
      expect(_Counter.mounts, 1);
    });

    testWidgets('an open drawer closes when the window stops being compact', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpApp(themedHost(const SizedBox()));
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) => buildShell(compact: CompactNavigation.drawer),
            ),
          );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDrawer), findsOneWidget);

      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveShell), findsNothing);
    });

    testWidgets('shrinking back leaves the drawer closed', (tester) async {
      await pumpShell(
        tester,
        700,
        buildShell(compact: CompactNavigation.drawer),
      );
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byTooltip('Open navigation'), findsOneWidget);
    });
  });
}
