import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import '../support/host.dart';

const _places = [
  ShellDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  ShellDestination(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
  ShellDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
];

Widget _shell({
  int selected = 0,
  ValueChanged<int>? onSelected,
  CompactNavigation compact = CompactNavigation.bar,
  Widget? title,
  List<ShellDestination> destinations = _places,
}) => AdaptiveShell(
  destinations: destinations,
  selectedIndex: selected,
  onSelected: onSelected ?? (_) {},
  compactNavigation: compact,
  title: title,
  body: const Align(
    alignment: Alignment.topLeft,
    child: Text('Body', key: Key('body')),
  ),
);

Future<void> _pump(
  WidgetTester tester,
  double width,
  Widget shell, {
  double height = 800,
  Locale locale = const Locale('en'),
  EdgeInsets? insets,
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpApp(
    themedHost(
      insets == null
          ? shell
          : Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(padding: insets, viewPadding: insets),
                child: shell,
              ),
            ),
      locale: locale,
    ),
  );
}

/// How many shapes the ink of a [Material] has drawn: a hover or focus
/// highlight adds one.
int _inkDraws(RenderObject ink) {
  var total = 0;
  for (final draw in [#drawRect, #drawRRect, #drawPath, #drawCircle]) {
    for (var n = 0; n < 8; n++) {
      try {
        expect(ink, paintsExactlyCountTimes(draw, n));
        total += n;
        break;
      } on TestFailure {
        continue;
      }
    }
  }
  return total;
}

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
        await _pump(tester, width, _shell());
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
      await _pump(tester, 400, _shell());
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
        await _pump(tester, width, _shell(onSelected: picked.add));
        await tester.tap(find.text('Inbox'));
        await tester.pump();
      }
      expect(picked, [1, 1, 1]);
    });

    testWidgets('shows the selected icon of the selected destination', (
      tester,
    ) async {
      await _pump(tester, 400, _shell());
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('a badge sits over the icon', (tester) async {
      await _pump(
        tester,
        700,
        _shell(
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
      await _pump(tester, 700, _shell(title: const Text('Acme')));
      expect(find.widgetWithText(AppBar, 'Acme'), findsOneWidget);
    });

    testWidgets('has no app bar without a title on a bar or a rail', (
      tester,
    ) async {
      await _pump(tester, 400, _shell());
      expect(find.byType(AppBar), findsNothing);
    });
  });

  group('drawer', () {
    testWidgets('opens from the menu button and closes from its own', (
      tester,
    ) async {
      await _pump(tester, 400, _shell(compact: CompactNavigation.drawer));
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);

      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDrawer), findsOneWidget);

      await tester.tap(find.byTooltip('Close navigation'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('picking a destination selects it and closes the drawer', (
      tester,
    ) async {
      final picked = <int>[];
      await _pump(
        tester,
        400,
        _shell(compact: CompactNavigation.drawer, onSelected: picked.add),
      );
      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(picked, [2]);
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('the open and close labels are localized', (tester) async {
      await _pump(
        tester,
        400,
        _shell(compact: CompactNavigation.drawer),
        locale: const Locale('fr'),
      );
      await tester.tap(find.byTooltip('Ouvrir la navigation'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Fermer la navigation'), findsOneWidget);
    });

    testWidgets('the menu button is a 48 dp button with its label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, 400, _shell(compact: CompactNavigation.drawer));
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(tooltip: 'Open navigation', isButton: true),
      );
      expect(tester.getSize(find.byType(IconButton)), const Size(48, 48));
      handle.dispose();
    });

    testWidgets('a wider window leaves the drawer for a rail', (tester) async {
      await _pump(tester, 700, _shell(compact: CompactNavigation.drawer));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byTooltip('Open navigation'), findsNothing);
    });
  });

  group('semantics', () {
    for (final width in [400.0, 700.0, 1000.0]) {
      testWidgets('the selected destination is selected at $width dp', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, width, _shell(selected: 1));
        expect(
          tester.getSemantics(find.text('Inbox').first),
          isSemantics(
            label: 'Inbox\nTab 2 of 3',
            isSelected: true,
            hasSelectedState: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );
        expect(
          tester.getSemantics(find.text('Home').first),
          isSemantics(
            label: 'Home\nTab 1 of 3',
            hasSelectedState: true,
            isFocusable: true,
            hasTapAction: true,
          ),
        );
        handle.dispose();
      });
    }

    testWidgets('destinations are at least 48 dp', (tester) async {
      for (final width in [400.0, 700.0, 1000.0]) {
        await _pump(tester, width, _shell());
        for (final label in ['Home', 'Inbox', 'Settings']) {
          final box = tester.getSemantics(find.text(label).first).rect;
          expect(box.height, greaterThanOrEqualTo(48), reason: '$label $width');
          expect(box.width, greaterThanOrEqualTo(48), reason: '$label $width');
        }
      }
    });

    testWidgets('the navigation is a labelled region, localized', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, 400, _shell());
      expect(find.bySemanticsLabel('Navigation'), findsOneWidget);
      await _pump(tester, 400, _shell(), locale: const Locale('fr'));
      expect(find.bySemanticsLabel('Navigation'), findsOneWidget);
      handle.dispose();
    });
  });

  group('keyboard and pointer', () {
    for (final width in [400.0, 700.0, 1000.0]) {
      testWidgets('Tab walks the destinations and Enter selects at $width', (
        tester,
      ) async {
        final picked = <int>[];
        await _pump(tester, width, _shell(onSelected: picked.add));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(picked, [1]);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(picked, [1, 2]);
      });
    }

    testWidgets('Shift+Tab goes back through the destinations', (tester) async {
      final picked = <int>[];
      await _pump(tester, 400, _shell(onSelected: picked.add));
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      }
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(picked, [1]);
    });

    for (final width in [400.0, 700.0, 1000.0]) {
      testWidgets('a mouse pointer highlights the destination at $width', (
        tester,
      ) async {
        await _pump(tester, width, _shell());
        final settings = find.text('Settings').first;
        final ink = tester.renderObject(
          find
              .ancestor(
                of: settings,
                matching: find.byWidgetPredicate(
                  (w) => w.runtimeType.toString() == '_InkFeatures',
                ),
              )
              .first,
        );
        final before = _inkDraws(ink);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(settings));
        await tester.pumpAndSettle();
        expect(_inkDraws(ink), greaterThan(before));
      });
    }
  });

  group('safe areas', () {
    const insets = EdgeInsets.fromLTRB(20, 30, 40, 50);

    testWidgets('bar: the body stays inside the top, left and right insets', (
      tester,
    ) async {
      await _pump(tester, 400, _shell(), insets: insets);
      final body = tester.getRect(find.byKey(const Key('body')));
      expect(body.left, greaterThanOrEqualTo(20));
      expect(body.top, greaterThanOrEqualTo(30));
      expect(
        tester.getRect(find.byType(NavigationBar)).top,
        greaterThanOrEqualTo(body.bottom),
      );
    });

    testWidgets('bar: the bar keeps the bottom inset', (tester) async {
      await _pump(tester, 400, _shell(), insets: insets);
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
      await _pump(tester, 700, _shell(), insets: insets);
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
      await _pump(
        tester,
        400,
        _shell(title: const Text('Acme')),
        insets: insets,
      );
      expect(tester.getRect(find.byType(AppBar)).height, 56 + 30);
      expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 56 + 30);
    });
  });

  group('errors', () {
    Future<List<String>> reported(WidgetTester tester, Widget shell) async {
      final messages = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (details) =>
          messages.add(details.exceptionAsString());
      addTearDown(() => FlutterError.onError = old);
      await _pump(tester, 400, shell);
      return messages;
    }

    testWidgets('fewer than two destinations reports and shows the body', (
      tester,
    ) async {
      final messages = await reported(
        tester,
        _shell(destinations: const [_one]),
      );
      expect(
        messages.single,
        contains('AdaptiveShell needs at least two destinations.'),
      );
      expect(find.text('Body'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('an out-of-range index reports and selects the nearest', (
      tester,
    ) async {
      final messages = await reported(tester, _shell(selected: 7));
      expect(
        messages.single,
        contains('AdaptiveShell.selectedIndex is out of range.'),
      );
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2,
      );
    });

    testWidgets('a valid shell reports nothing', (tester) async {
      expect(await reported(tester, _shell()), isEmpty);
    });
  });
}

const _one = ShellDestination(icon: Icon(Icons.home), label: 'Home');
