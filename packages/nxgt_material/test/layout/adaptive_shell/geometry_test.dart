import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import '../../support/host.dart';
import 'adaptive_shell_harness.dart';

void main() {
  group('safe areas', () {
    const insets = EdgeInsets.fromLTRB(20, 30, 40, 50);

    testWidgets('bar: the body stays inside the top, left and right insets', (
      tester,
    ) async {
      await pumpShell(tester, 400, buildShell(), insets: insets);
      final body = tester.getRect(find.byKey(const Key('body')));
      expect(body.left, greaterThanOrEqualTo(20));
      expect(body.top, greaterThanOrEqualTo(30));
      expect(
        tester.getRect(find.byType(NavigationBar)).top,
        greaterThanOrEqualTo(body.bottom),
      );
    });

    testWidgets('bar: the bar keeps the bottom inset', (tester) async {
      await pumpShell(tester, 400, buildShell(), insets: insets);
      expect(
        tester.getRect(find.byType(NavigationBar)).bottom,
        lessThanOrEqualTo(800 - 0),
      );
      final destination = tester.getRect(find.text('Home'));
      expect(destination.bottom, lessThanOrEqualTo(800 - 50));
    });

    testWidgets('rail: the rail keeps the left inset, the body the right', (
      tester,
    ) async {
      await pumpShell(tester, 700, buildShell(), insets: insets);
      expect(
        tester.getRect(find.byType(NavigationRail)).left,
        greaterThanOrEqualTo(0),
      );
      expect(
        tester.getTopLeft(find.byType(NavigationRail)).dx +
            tester.getSize(find.byType(NavigationRail)).width,
        greaterThanOrEqualTo(20 + 72),
      );
      final body = tester.getRect(find.byKey(const Key('body')));
      expect(body.top, greaterThanOrEqualTo(30));
      expect(body.left, greaterThan(72));
    });

    testWidgets('with an app bar the bar takes the top inset, not the body', (
      tester,
    ) async {
      await pumpShell(
        tester,
        400,
        buildShell(title: const Text('Acme')),
        insets: insets,
      );
      expect(tester.getRect(find.byType(AppBar)).height, 56 + 30);
      expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 56 + 30);
    });
  });

  group('right to left', () {
    const insets = EdgeInsets.fromLTRB(20, 30, 40, 50);

    for (final width in [700.0, 1000.0]) {
      testWidgets('the navigation takes the start inset at $width dp', (
        tester,
      ) async {
        tester.view
          ..physicalSize = Size(width, 800)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpApp(
          themedHost(
            Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(padding: insets, viewPadding: insets),
                  child: buildShell(),
                ),
              ),
            ),
          ),
        );
        final nav = width < 840
            ? find.byType(NavigationRail)
            : find.byType(NavigationDrawer);
        // The navigation sits at the right (start) and stays clear of the
        // 40 dp inset there; the body stays clear of the 20 dp left inset.
        expect(tester.getRect(nav).right, lessThanOrEqualTo(width - 40));
        expect(
          tester.getRect(find.byKey(const Key('body'))).left,
          greaterThanOrEqualTo(20),
        );
      });
    }
  });

  group('slots', () {
    testWidgets('an appBar overrides the title; actions fill the default one', (
      tester,
    ) async {
      await pumpShell(
        tester,
        400,
        AdaptiveShell(
          destinations: shellPlaces,
          selectedIndex: 0,
          onSelected: (_) {},
          title: const Text('Ignored'),
          appBar: AppBar(title: const Text('Mine')),
          body: const SizedBox(),
        ),
      );
      expect(find.text('Mine'), findsOneWidget);
      expect(find.text('Ignored'), findsNothing);

      await pumpShell(
        tester,
        400,
        AdaptiveShell(
          destinations: shellPlaces,
          selectedIndex: 0,
          onSelected: (_) {},
          title: const Text('Acme'),
          actions: const [Icon(Icons.search)],
          body: const SizedBox(),
        ),
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('forwards the button location and the bottom sheet', (
      tester,
    ) async {
      await pumpShell(
        tester,
        400,
        AdaptiveShell(
          destinations: shellPlaces,
          selectedIndex: 0,
          onSelected: (_) {},
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          bottomSheet: const Text('Sheet'),
          body: const SizedBox(),
        ),
      );
      expect(find.text('Sheet'), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(FloatingActionButton)).dx,
        lessThan(100),
      );
    });

    testWidgets('a screen can nest its own Scaffold in the body', (
      tester,
    ) async {
      await pumpShell(
        tester,
        700,
        AdaptiveShell(
          destinations: shellPlaces,
          selectedIndex: 0,
          onSelected: (_) {},
          body: Scaffold(appBar: AppBar(title: const Text('Inner'))),
        ),
      );
      expect(find.text('Inner'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
