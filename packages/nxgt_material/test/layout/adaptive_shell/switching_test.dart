import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import 'adaptive_shell_harness.dart';

void main() {
  group('switching', () {
    final cases = <double, (bool bar, bool rail, bool drawer)>{
      400: (true, false, false),
      599: (true, false, false),
      600: (false, true, false),
      839: (false, true, false),
      840: (false, false, true),
      1300: (false, false, true),
      1700: (false, false, true),
    };
    for (final MapEntry(key: width, value: expected) in cases.entries) {
      testWidgets('at $width dp', (tester) async {
        await pumpShell(tester, width, buildShell());
        expect(
          find.byType(NavigationBar),
          expected.$1 ? findsOne : findsNothing,
        );
        expect(
          find.byType(NavigationRail),
          expected.$2 ? findsOne : findsNothing,
        );
        expect(
          find.byType(NavigationDrawer),
          expected.$3 ? findsOne : findsNothing,
        );
        expect(find.byKey(const Key('body')), findsOneWidget);
      });
    }

    testWidgets('swaps when the window is resized, keeping the body state', (
      tester,
    ) async {
      await pumpShell(tester, 400, buildShell());
      expect(find.byType(NavigationBar), findsOneWidget);
      tester.view.physicalSize = const Size(700, 800);
      await tester.pump();
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);
      tester.view.physicalSize = const Size(1000, 800);
      await tester.pump();
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('selecting a destination calls onSelected on each', (
      tester,
    ) async {
      final picked = <int>[];
      for (final width in [400.0, 700.0, 1000.0]) {
        await pumpShell(tester, width, buildShell(onSelected: picked.add));
        await tester.tap(find.text('Inbox'));
        await tester.pump();
      }
      expect(picked, [1, 1, 1]);
    });

    testWidgets('shows the selected icon of the selected destination', (
      tester,
    ) async {
      await pumpShell(tester, 400, buildShell());
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('a badge sits over the icon', (tester) async {
      await pumpShell(
        tester,
        700,
        buildShell(
          destinations: const [
            ShellDestination(
              icon: Icon(Icons.inbox_outlined),
              label: 'Inbox',
              badge: Badge(label: Text('3')),
            ),
            ShellDestination(icon: Icon(Icons.home), label: 'Home'),
          ],
        ),
      );
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows a shared title in an app bar', (tester) async {
      await pumpShell(tester, 700, buildShell(title: const Text('Acme')));
      expect(find.widgetWithText(AppBar, 'Acme'), findsOneWidget);
    });

    testWidgets('has no app bar without a title on a bar or a rail', (
      tester,
    ) async {
      await pumpShell(tester, 400, buildShell());
      expect(find.byType(AppBar), findsNothing);
    });
  });

  group('boundaries', () {
    final cases = <double, bool>{
      1199: false,
      1200: true,
      1599: true,
      1600: true,
    };
    for (final MapEntry(key: width) in cases.entries) {
      testWidgets('a standing drawer at $width dp', (tester) async {
        await pumpShell(tester, width, buildShell());
        expect(find.byType(NavigationDrawer), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });
    }
  });
}
