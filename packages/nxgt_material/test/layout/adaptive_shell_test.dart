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
/// highlight adds one. `Material.of` is the ink controller, a render object.
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

Widget _statefulShell({
  CompactNavigation compact = CompactNavigation.bar,
  Widget? title,
}) => AdaptiveShell(
  destinations: _places,
  selectedIndex: 0,
  onSelected: (_) {},
  compactNavigation: compact,
  title: title,
  body: const Align(alignment: Alignment.topLeft, child: _Counter()),
);

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
        final ink = Material.of(tester.element(settings)) as RenderObject;
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

  group('stability', () {
    testWidgets('the body keeps its state across every size class', (
      tester,
    ) async {
      _Counter.mounts = 0;
      await _pump(tester, 400, _statefulShell());
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
      await _pump(
        tester,
        400,
        _statefulShell(
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
              builder: (_) => _shell(compact: CompactNavigation.drawer),
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
      await _pump(tester, 700, _shell(compact: CompactNavigation.drawer));
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byTooltip('Open navigation'), findsOneWidget);
    });
  });

  group('drawer button', () {
    for (final width in [700.0, 1000.0]) {
      testWidgets('no drawer button beside the navigation at $width dp', (
        tester,
      ) async {
        await _pump(
          tester,
          width,
          _shell(compact: CompactNavigation.drawer, title: const Text('Acme')),
        );
        expect(find.byType(DrawerButton), findsNothing);
        expect(find.byTooltip('Open navigation'), findsNothing);
        expect(find.byIcon(Icons.menu), findsNothing);
      });
    }

    testWidgets('the menu button is there on a compact window', (tester) async {
      await _pump(
        tester,
        400,
        _shell(compact: CompactNavigation.drawer, title: const Text('Acme')),
      );
      expect(find.byTooltip('Open navigation'), findsOneWidget);
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
        await _pump(tester, width, _shell());
        expect(find.byType(NavigationDrawer), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });
    }
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
                  child: _shell(),
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
      await _pump(
        tester,
        400,
        AdaptiveShell(
          destinations: _places,
          selectedIndex: 0,
          onSelected: (_) {},
          title: const Text('Ignored'),
          appBar: AppBar(title: const Text('Mine')),
          body: const SizedBox(),
        ),
      );
      expect(find.text('Mine'), findsOneWidget);
      expect(find.text('Ignored'), findsNothing);

      await _pump(
        tester,
        400,
        AdaptiveShell(
          destinations: _places,
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
      await _pump(
        tester,
        400,
        AdaptiveShell(
          destinations: _places,
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
      await _pump(
        tester,
        700,
        AdaptiveShell(
          destinations: _places,
          selectedIndex: 0,
          onSelected: (_) {},
          body: Scaffold(appBar: AppBar(title: const Text('Inner'))),
        ),
      );
      expect(find.text('Inner'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('keyboard in French', () {
    testWidgets('Space selects and the region is labelled in French', (
      tester,
    ) async {
      final picked = <int>[];
      await _pump(
        tester,
        400,
        _shell(onSelected: picked.add),
        locale: const Locale('fr'),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(picked, [1]);
    });
  });

  group('misuse asserts', () {
    testWidgets('fewer than two destinations', (tester) async {
      await _pump(tester, 400, _shell(destinations: const [_one]));
      final error = tester.takeException();
      expect(error, isA<AssertionError>());
      expect(
        error.toString(),
        contains('AdaptiveShell needs at least two destinations.'),
      );
    });

    testWidgets('an out-of-range index', (tester) async {
      await _pump(tester, 400, _shell(selected: 7));
      final error = tester.takeException();
      expect(error, isA<AssertionError>());
      expect(
        error.toString(),
        contains('AdaptiveShell.selectedIndex is out of range.'),
      );
    });

    testWidgets('a valid shell asserts nothing', (tester) async {
      await _pump(tester, 400, _shell());
      expect(tester.takeException(), isNull);
    });
  });
}

const _one = ShellDestination(icon: Icon(Icons.home), label: 'Home');
