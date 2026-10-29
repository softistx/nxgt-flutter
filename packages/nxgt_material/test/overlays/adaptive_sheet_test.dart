import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/overlays.dart';

import '../support/host.dart';

const _compact = Size(360, 800);
const _medium = Size(900, 800);

/// Opens a sheet from a button; `result` receives the popped value.
class _Opener extends StatelessWidget {
  const new({required this.onResult, required this.focusNode, this.content});

  final void Function(String?) onResult;
  final FocusNode focusNode;
  final Widget? content;

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      autofocus: true,
      focusNode: focusNode,
      onPressed: () async => onResult(
        await context.showAdaptiveSheet<String>(
          title: 'Filters',
          builder: (context) =>
              content ??
              Column(
                children: [
                  const TextField(key: Key('field')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'done'),
                    child: const Text('Apply'),
                  ),
                ],
              ),
        ),
      ),
      child: const Text('Open'),
    ),
  );
}

late FocusNode _node;

Future<void> _open(
  WidgetTester tester, {
  Size size = _compact,
  void Function(String?)? onResult,
  Widget? content,
  TextDirection? direction,
  double scale = 1,
  double keyboard = 0,
  bool reduceMotion = false,
  EdgeInsets padding = EdgeInsets.zero,
  bool settle = true,
  Locale locale = const Locale('en'),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _node = FocusNode();
  addTearDown(_node.dispose);
  tester.view.padding = FakeViewPadding(
    left: padding.left,
    top: padding.top,
    right: padding.right,
    bottom: padding.bottom,
  );
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpApp(
    themedHost(
      _Opener(onResult: onResult ?? (_) {}, focusNode: _node, content: content),
      locale: locale,
      direction: direction,
      disableAnimations: reduceMotion,
    ),
  );
  await tester.tap(find.text('Open'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// The Material 3 drag handle: a 32 x 4 bar.
final _handle = find.byWidgetPredicate(
  (w) =>
      w is Container &&
      w.constraints == const BoxConstraints.tightFor(width: 32, height: 4),
);

void main() {
  group('layout', () {
    testWidgets('compact: a bottom sheet with a drag handle', (tester) async {
      await _open(tester);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(_handle, findsOneWidget);
      final sheet = tester.getRect(find.byType(BottomSheet));
      expect(sheet.bottom, 800);
      expect(sheet.height, lessThanOrEqualTo(800 * 0.9));
    });

    testWidgets('compact: content stays above a 300 dp keyboard', (
      tester,
    ) async {
      await _open(tester, keyboard: 300);

      expect(tester.getRect(find.text('Apply')).bottom, lessThanOrEqualTo(500));
      expect(
        tester.getRect(find.byKey(const Key('field'))).bottom,
        lessThan(500),
      );
    });

    testWidgets('medium: a side sheet on the right in LTR', (tester) async {
      await _open(tester, size: _medium);

      expect(find.byType(BottomSheet), findsNothing);
      final sheet = tester.getRect(
        find
            .ancestor(of: find.text('Filters'), matching: find.byType(Material))
            .first,
      );
      expect(sheet.right, 900);
      expect(sheet.width, 400);
      expect(sheet.top, 0);
      expect(sheet.bottom, 800);
    });

    testWidgets('medium: a side sheet on the left in RTL', (tester) async {
      await _open(tester, size: _medium, direction: TextDirection.rtl);

      final sheet = tester.getRect(
        find
            .ancestor(of: find.text('Filters'), matching: find.byType(Material))
            .first,
      );
      expect(sheet.left, 0);
      expect(sheet.width, 400);
    });
  });

  group('medium insets', () {
    testWidgets('respect the safe area (top 40, end 30)', (tester) async {
      await _open(
        tester,
        size: _medium,
        padding: const EdgeInsets.only(top: 40, right: 30),
      );

      final close = tester.getRect(find.byType(IconButton));
      expect(close.top, greaterThanOrEqualTo(40));
      expect(close.right, lessThanOrEqualTo(900 - 30));
    });

    testWidgets('stay above a 300 dp keyboard', (tester) async {
      await _open(tester, size: _medium, keyboard: 300);

      expect(
        tester.getRect(find.text('Apply')).bottom,
        lessThanOrEqualTo(800 - 300),
      );
    });
  });

  group('reduced motion', () {
    for (final size in const [_compact, _medium]) {
      testWidgets('the sheet is in place after one pump at ${size.width} dp', (
        tester,
      ) async {
        await _open(tester, size: size, reduceMotion: true, settle: false);
        await tester.pump();

        final rect = tester.getRect(find.byType(AdaptiveSheet));
        expect(rect.bottom, lessThanOrEqualTo(800));
        expect(rect.right, lessThanOrEqualTo(size.width));
        expect(rect.top, lessThan(800));
        if (size == _medium) expect(rect.right, 900);
      });
    }
  });

  group('route semantics', () {
    for (final size in const [_compact, _medium]) {
      testWidgets('exactly one namesRoute node at ${size.width} dp', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _open(tester, size: size);

        final named = find.semantics
            .byPredicate((n) => n.flagsCollection.namesRoute)
            .evaluate();
        expect(named, hasLength(1));
        expect(find.bySemanticsLabel('Filters'), findsWidgets);
        handle.dispose();
      });
    }
  });

  group('result', () {
    for (final size in const [_compact, _medium]) {
      testWidgets('returns the popped value at ${size.width} dp', (
        tester,
      ) async {
        var called = false;
        String? result;
        await _open(
          tester,
          size: size,
          onResult: (v) {
            called = true;
            result = v;
          },
        );
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(result, 'done');
        expect(find.text('Filters'), findsNothing);
      });

      testWidgets('close button returns null at ${size.width} dp', (
        tester,
      ) async {
        var called = false;
        String? result = 'x';
        await _open(
          tester,
          size: size,
          onResult: (v) {
            called = true;
            result = v;
          },
        );
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(result, isNull);
        expect(find.text('Filters'), findsNothing);
      });

      testWidgets('Escape returns null at ${size.width} dp', (tester) async {
        var called = false;
        await _open(tester, size: size, onResult: (v) => called = v == null);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(find.text('Filters'), findsNothing);
      });

      testWidgets('a tap on the barrier returns null at ${size.width} dp', (
        tester,
      ) async {
        var called = false;
        await _open(tester, size: size, onResult: (v) => called = v == null);
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();

        expect(called, isTrue);
        expect(find.text('Filters'), findsNothing);
      });
    }
  });

  group('focus', () {
    for (final size in const [_compact, _medium]) {
      testWidgets('is trapped in the sheet and returns to the opener '
          'at ${size.width} dp', (tester) async {
        await _open(tester, size: size);
        expect(_node.hasFocus, isFalse);

        for (var i = 0; i < 6; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(_node.hasFocus, isFalse, reason: 'tab $i left the sheet');
        }
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();

        expect(_node.hasFocus, isTrue);
      });
    }
  });

  group('accessibility', () {
    testWidgets('the title is a header and names the route', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester, size: _medium);

      expect(
        tester.getSemantics(find.text('Filters')),
        isSemantics(label: 'Filters', isHeader: true),
      );
      final named = find.semantics
          .byPredicate(
            (n) =>
                n.flagsCollection.scopesRoute && n.flagsCollection.namesRoute,
          )
          .evaluate()
          .map((n) => n.getSemanticsData().label);
      expect(named, contains('Filters'));
      handle.dispose();
    });

    testWidgets('the close button is labelled, in French too', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester, locale: const Locale('fr'));

      expect(find.byTooltip('Fermer'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the close button is a 48 dp target, also on macOS', (
      tester,
    ) async {
      for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        await _open(tester);

        final size = tester.getSize(find.byType(IconButton));
        expect(size.width, greaterThanOrEqualTo(48), reason: '$platform');
        expect(size.height, greaterThanOrEqualTo(48), reason: '$platform');
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });

  group('long content', () {
    for (final size in const [_compact, _medium]) {
      testWidgets('scrolls at text scale 2 at ${size.width} dp', (
        tester,
      ) async {
        await _open(
          tester,
          size: size,
          scale: 2,
          content: Column(
            children: [
              for (var i = 0; i < 40; i++) Text('Line number $i of the list'),
            ],
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(Scrollable), findsWidgets);
        final sheetHeight = tester.getRect(find.byType(AdaptiveSheet)).height;
        expect(sheetHeight, lessThanOrEqualTo(800));
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -2000),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('AdaptiveSheet', () {
    testWidgets('survives IntrinsicHeight', (tester) async {
      await tester.pumpApp(
        themedHost(
          const SizedBox(
            width: 360,
            child: IntrinsicHeight(
              child: AdaptiveSheet(title: 'Filters', child: Text('Body')),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('asserts an empty title', (tester) async {
      expect(
        () => AdaptiveSheet(title: '', child: const SizedBox()),
        throwsAssertionError,
      );
    });
  });
}
