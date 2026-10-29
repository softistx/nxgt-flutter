import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/overlays.dart';

import '../support/host.dart';

const _compact = Size(360, 800);
const _medium = Size(900, 800);

late FocusNode _openerNode;

/// Opens a form dialog from a button; `result` receives the popped value.
class _Opener extends StatelessWidget {
  const new({required this.onResult, required this.onSubmit});

  final void Function(String?) onResult;
  final Future<String> Function() onSubmit;

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      autofocus: true,
      focusNode: _openerNode,
      onPressed: () async => onResult(
        await context.showFormDialog<String>(
          title: 'New invoice',
          submitLabel: 'Save',
          builder: (context) => TextFormField(
            key: const Key('name'),
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
          ),
          onSubmit: onSubmit,
        ),
      ),
      child: const Text('Open'),
    ),
  );
}

Future<void> _open(
  WidgetTester tester, {
  void Function(String?)? onResult,
  Future<String> Function()? onSubmit,
  Size size = _medium,
  Locale locale = const Locale('en'),
  double scale = 1,
  double keyboard = 0,
  bool reduceMotion = false,
  bool settle = true,
  TextDirection? direction,
  Brightness brightness = Brightness.light,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  _openerNode = FocusNode();
  addTearDown(_openerNode.dispose);
  await tester.pumpApp(
    themedHost(
      _Opener(
        onResult: onResult ?? (_) {},
        onSubmit: onSubmit ?? () async => 'saved',
      ),
      locale: locale,
      direction: direction,
      brightness: brightness,
      disableAnimations: reduceMotion,
    ),
  );
  await tester.tap(find.text('Open'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
}

Finder get _field => find.byKey(const Key('name'));
Finder get _saveButton => find.ancestor(
  of: find.text('Save'),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);
Finder get _submit => find.text('Save');
Finder get _discardTitle => find.text('Discard changes?');

Future<void> _type(WidgetTester tester) async {
  await tester.enterText(_field, 'ACME');
  await tester.pump();
}

void main() {
  group('layout by window size', () {
    testWidgets('compact is full-screen with an app bar', (tester) async {
      await _open(tester, size: _compact);

      expect(find.byType(AlertDialog), findsNothing);
      final bar = find.byType(AppBar);
      expect(bar, findsOneWidget);
      expect(
        find.descendant(of: bar, matching: find.text('New invoice')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bar, matching: find.byIcon(Icons.close)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: bar,
          matching: find.widgetWithText(TextButton, 'Save'),
        ),
        findsOneWidget,
      );
      expect(tester.getSize(find.byType(Scaffold).last), _compact);
    });

    testWidgets('medium is a dialog up to 560 dp wide', (tester) async {
      await _open(tester);

      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      final surface = find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Material),
          )
          .first;
      final width = tester.getSize(surface).width;
      expect(width, lessThanOrEqualTo(560));
      expect(width, greaterThan(280));
    });

    testWidgets('the size is read when it opens', (tester) async {
      await _open(tester, size: _compact);
      tester.view.physicalSize = _medium;
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('submit', () {
    for (final size in [_compact, _medium]) {
      testWidgets('invalid stays open and sends nothing at ${size.width}', (
        tester,
      ) async {
        var calls = 0;
        String? result = 'unset';
        await _open(
          tester,
          size: size,
          onResult: (v) => result = v,
          onSubmit: () async {
            calls++;
            return 'saved';
          },
        );

        await tester.tap(_submit);
        await tester.pumpAndSettle();

        expect(calls, 0);
        expect(result, 'unset');
        expect(find.text('Required'), findsOneWidget);
        expect(find.text('New invoice'), findsOneWidget);
      });

      testWidgets('valid pops the value at ${size.width}', (tester) async {
        String? result;
        await _open(tester, size: size, onResult: (v) => result = v);

        await _type(tester);
        await tester.tap(_submit);
        await tester.pumpAndSettle();

        expect(result, 'saved');
        expect(find.text('New invoice'), findsNothing);
        expect(_discardTitle, findsNothing);
      });
    }

    testWidgets('is locked while it runs and one frame after success', (
      tester,
    ) async {
      String? result;
      var calls = 0;
      final gate = Completer<String>();
      await _open(
        tester,
        onResult: (v) => result = v,
        onSubmit: () {
          calls++;
          return gate.future;
        },
      );
      await _type(tester);

      await tester.tap(_submit);
      await tester.pump();
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();

      expect(calls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
            .onPressed,
        isNull,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(_discardTitle, findsNothing);

      gate.complete('done');
      await tester.pump();
      // One frame after success the dialog is still there and still locked.
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(_discardTitle, findsNothing);
      expect(calls, 1);

      await tester.pumpAndSettle();
      expect(result, 'done');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('a failing onSubmit is reported and stays open', (
      tester,
    ) async {
      String? result = 'unset';
      await _open(
        tester,
        size: _compact,
        onResult: (v) => result = v,
        onSubmit: () async => throw StateError('boom'),
      );
      await _type(tester);

      await tester.tap(_submit);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isA<StateError>());
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(result, 'unset');
      // Still usable: it can be sent again.
      await tester.tap(_submit);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isA<StateError>());
    });
  });

  group('closing', () {
    for (final size in [_compact, _medium]) {
      final name = size == _compact ? 'compact' : 'medium';

      Future<void> closeByButton(WidgetTester tester) => size == _compact
          ? tester.tap(find.byIcon(Icons.close))
          : tester.tap(find.text('Cancel'));

      testWidgets('$name: clean close pops null at once', (tester) async {
        String? result = 'unset';
        await _open(tester, size: size, onResult: (v) => result = v);

        await closeByButton(tester);
        await tester.pumpAndSettle();

        expect(result, isNull);
        expect(_discardTitle, findsNothing);
        expect(find.text('New invoice'), findsNothing);
      });

      testWidgets('$name: dirty close asks, Cancel keeps it open', (
        tester,
      ) async {
        String? result = 'unset';
        await _open(tester, size: size, onResult: (v) => result = v);
        await _type(tester);

        await closeByButton(tester);
        await tester.pumpAndSettle();
        expect(_discardTitle, findsOneWidget);
        expect(find.text('Discard'), findsOneWidget);

        await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
        await tester.pumpAndSettle();

        expect(_discardTitle, findsNothing);
        expect(find.text('New invoice'), findsOneWidget);
        expect(find.text('ACME'), findsOneWidget);
        expect(result, 'unset');
      });

      testWidgets('$name: dirty close, Discard closes with null', (
        tester,
      ) async {
        String? result = 'unset';
        await _open(tester, size: size, onResult: (v) => result = v);
        await _type(tester);

        await closeByButton(tester);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();

        expect(result, isNull);
        expect(find.text('New invoice'), findsNothing);
        expect(_discardTitle, findsNothing);
      });

      testWidgets('$name: Escape and back ask when dirty, close when clean', (
        tester,
      ) async {
        String? result = 'unset';
        await _open(tester, size: size, onResult: (v) => result = v);
        await _type(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(_discardTitle, findsOneWidget);
        await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
        await tester.pumpAndSettle();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(_discardTitle, findsOneWidget);
        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();
        expect(result, isNull);

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(_discardTitle, findsNothing);
        expect(find.text('New invoice'), findsNothing);
      });
    }

    testWidgets('a tap on the barrier asks when dirty, closes when clean', (
      tester,
    ) async {
      String? result = 'unset';
      await _open(tester, onResult: (v) => result = v);
      await _type(tester);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(_discardTitle, findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(result, isNull);

      result = 'unset';
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(_discardTitle, findsNothing);
    });

    testWidgets('the discard question is destructive', (tester) async {
      await _open(tester);
      await _type(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final confirm = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Discard'),
      );
      expect(confirm.onPressed, isNotNull);
      expect(find.textContaining('lost'), findsOneWidget);
    });
  });

  group('French', () {
    testWidgets('the discard strings are localized', (tester) async {
      await _open(tester, locale: const Locale('fr'));
      await _type(tester);

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Abandonner les modifications ?'), findsOneWidget);
      expect(find.text('Abandonner'), findsOneWidget);
      expect(find.textContaining('perdues'), findsOneWidget);
    });
  });

  group('semantics', () {
    for (final size in [_compact, _medium]) {
      testWidgets('names its route once at ${size.width}', (tester) async {
        final handle = tester.ensureSemantics();
        await _open(tester, size: size);

        // The label sits on the node or, in the app bar, on its child.
        String nameOf(SemanticsNode node) {
          final labels = <String>[node.getSemanticsData().label];
          node.visitChildren((child) {
            labels.add(nameOf(child));
            return true;
          });
          return labels.join(' ');
        }

        final named = find.semantics
            .byPredicate((n) => n.flagsCollection.namesRoute)
            .evaluate()
            .where((n) => nameOf(n).contains('New invoice'));
        expect(named, hasLength(1));
        handle.dispose();
      });

      testWidgets('the title is a header at ${size.width}', (tester) async {
        final handle = tester.ensureSemantics();
        await _open(tester, size: size);

        final header = find.semantics.byPredicate(
          (n) =>
              n.flagsCollection.isHeader &&
              n.getSemanticsData().label.contains('New invoice'),
        );
        expect(header, findsOneWidget);
        handle.dispose();
      });
    }

    testWidgets('the close button is labelled', (tester) async {
      await _open(tester, size: _compact);

      expect(find.byTooltip('Close'), findsOneWidget);
    });
  });

  group('focus', () {
    for (final size in [_compact, _medium]) {
      testWidgets('returns to the opener after close at ${size.width}', (
        tester,
      ) async {
        await _open(tester, size: size);
        expect(_openerNode.hasFocus, isFalse);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(_openerNode.hasFocus, isTrue);
      });
    }
  });

  group('layout', () {
    testWidgets('actions keep 48 dp targets, also on macOS', (tester) async {
      for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
        for (final size in [_compact, _medium]) {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          await _open(tester, size: size);

          final finders = [
            _saveButton,
            if (size == _compact)
              find.byType(IconButton)
            else
              find.widgetWithText(TextButton, 'Cancel'),
          ];
          for (final finder in finders) {
            final rect = tester.getRect(finder);
            expect(rect.height, greaterThanOrEqualTo(48), reason: '$platform');
            expect(rect.width, greaterThanOrEqualTo(48), reason: '$platform');
          }
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          debugDefaultTargetPlatformOverride = null;
        }
      }
    });

    for (final size in [_compact, _medium]) {
      testWidgets('works in RTL at ${size.width}', (tester) async {
        await _open(tester, size: size, direction: TextDirection.rtl);

        expect(tester.takeException(), isNull);
        final submit = tester.getRect(_saveButton);
        final close = size == _compact
            ? tester.getRect(find.byIcon(Icons.close))
            : tester.getRect(find.text('Cancel'));
        if (size == _compact) {
          // The close button leads, at the right; Save trails, at the left.
          expect(close.center.dx, greaterThan(submit.center.dx));
        } else {
          expect(close.center.dx, greaterThan(submit.center.dx));
        }
      });
    }

    testWidgets('text scale 2 at 360 dp scrolls without overflow', (
      tester,
    ) async {
      await _open(tester, size: _compact, scale: 2);

      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('text scale 2 in the dialog scrolls without overflow', (
      tester,
    ) async {
      await _open(tester, scale: 2, size: const Size(600, 400));

      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the focused field above the keyboard', (tester) async {
      await _open(tester, size: _compact, keyboard: 300);
      await tester.tap(_field);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final bottom = tester.getRect(_field).bottom;
      expect(bottom, lessThanOrEqualTo(_compact.height - 300));
    });

    testWidgets('reduced motion opens and closes with no animation', (
      tester,
    ) async {
      for (final size in [_compact, _medium]) {
        await _open(tester, size: size, reduceMotion: true, settle: false);
        expect(find.text('New invoice'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        await tester.pump();
        expect(find.text('New invoice'), findsNothing);
      }
    });
  });

  group('FormDialog', () {
    testWidgets('survives IntrinsicHeight', (tester) async {
      await tester.pumpApp(
        themedHost(
          Center(
            child: IntrinsicHeight(
              child: FormDialog<void>(
                title: 'New invoice',
                onSubmit: () async {},
                child: const TextField(),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('New invoice'), findsOneWidget);
    });

    testWidgets('asserts an empty title', (tester) async {
      expect(
        () => FormDialog<void>(
          title: '',
          onSubmit: () async {},
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });
  });
}
