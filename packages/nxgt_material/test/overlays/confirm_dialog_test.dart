import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/overlays.dart';
import 'package:nxgt_material/src/theme/contrast.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';

import '../support/host.dart';

/// A button that opens the dialog and reports the answer.
class _Opener extends StatelessWidget {
  const new({
    required this.onResult,
    this.destructive = false,
    this.onConfirm,
    this.message = 'This cannot be undone.',
    this.confirmLabel,
  });

  final ValueChanged<bool> onResult;
  final bool destructive;
  final Future<void> Function()? onConfirm;
  final String message;
  final String? confirmLabel;

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      autofocus: true,
      onPressed: () async => onResult(
        await context.confirm(
          title: 'Delete invoice?',
          message: message,
          confirmLabel: confirmLabel,
          destructive: destructive,
          onConfirm: onConfirm,
        ),
      ),
      child: const Text('Open'),
    ),
  );
}

Future<void> _open(
  WidgetTester tester,
  ValueChanged<bool> onResult, {
  bool destructive = false,
  Future<void> Function()? onConfirm,
  String message = 'This cannot be undone.',
  String? confirmLabel,
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  double scale = 1,
  Size size = const Size(800, 900),
  TextDirection? direction,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Widget opener = _Opener(
    onResult: onResult,
    destructive: destructive,
    onConfirm: onConfirm,
    message: message,
    confirmLabel: confirmLabel,
  );
  if (direction != null) {
    opener = Directionality(textDirection: direction, child: opener);
  }
  await tester.pumpApp(
    themedHost(
      MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(scale)),
        child: opener,
      ),
      locale: locale,
      brightness: brightness,
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Color _fill(WidgetTester tester) => tester
    .widget<Material>(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.byType(Material),
      ),
    )
    .color!;

/// The nearest [T] above the focused widget, or `null`.
T? _focusedIn<T extends Widget>() => FocusManager.instance.primaryFocus?.context
    ?.findAncestorWidgetOfExactType<T>();

void main() {
  testWidgets('shows the title, the message and localized actions', (
    tester,
  ) async {
    await _open(tester, (_) {});

    expect(find.text('Delete invoice?'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Confirm'), findsOneWidget);
  });

  testWidgets('French labels', (tester) async {
    await _open(tester, (_) {}, locale: const Locale('fr'));

    expect(find.text('Annuler'), findsOneWidget);
    expect(find.text('Confirmer'), findsOneWidget);
  });

  testWidgets('a confirmLabel replaces the default', (tester) async {
    await _open(tester, (_) {}, confirmLabel: 'Delete');

    expect(find.widgetWithText(FilledButton, 'Delete'), findsOneWidget);
    expect(find.text('Confirm'), findsNothing);
  });

  testWidgets('is a dialog at every window size', (tester) async {
    for (final size in const [Size(360, 800), Size(1400, 900)]) {
      await _open(tester, (_) {}, size: size);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('names and scopes its route', (tester) async {
    final handle = tester.ensureSemantics();
    await _open(tester, (_) {});

    final named = find.semantics
        .byPredicate(
          (n) => n.flagsCollection.scopesRoute && n.flagsCollection.namesRoute,
        )
        .evaluate()
        .map((n) => n.getSemanticsData().label);
    expect(named, contains('Delete invoice?'));
    handle.dispose();
  });

  group('answers', () {
    testWidgets('confirm returns true', (tester) async {
      bool? result;
      await _open(tester, (v) => result = v);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('cancel returns false', (tester) async {
      bool? result;
      await _open(tester, (v) => result = v);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('Escape returns false', (tester) async {
      bool? result;
      await _open(tester, (v) => result = v);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('a tap on the barrier returns false', (tester) async {
      bool? result;
      await _open(tester, (v) => result = v);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('the system back returns false', (tester) async {
      bool? result;
      await _open(tester, (v) => result = v);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });

  group('onConfirm', () {
    testWidgets('is busy, cannot be dismissed, then pops true', (tester) async {
      bool? result;
      var calls = 0;
      final gate = Completer<void>();
      await _open(
        tester,
        (v) => result = v,
        onConfirm: () {
          calls++;
          return gate.future;
        },
      );

      await tester.tap(find.text('Confirm'));
      await tester.pump();
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();

      expect(calls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(result, isNull);

      gate.complete();
      await tester.pumpAndSettle();
      expect(result, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('a throw is reported and the dialog stays open', (
      tester,
    ) async {
      bool? result;
      await _open(
        tester,
        (v) => result = v,
        onConfirm: () async => throw StateError('boom'),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      final error = tester.takeException();
      expect(error, isA<StateError>());
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(result, isNull);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });

  group('destructive', () {
    testWidgets('draws the confirm action with the error tone at AA', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await _open(tester, (_) {}, destructive: true, brightness: brightness);

        final error = tester.element(find.byType(AlertDialog)).tones.error;
        expect(_fill(tester), error.color);
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        final style = FilledButtonTheme.of(
          tester.element(find.byType(FilledButton)),
        ).style!;
        expect(style.foregroundColor!.resolve({}), error.onColor);
        expect(
          wcagContrast(error.onColor, error.color),
          greaterThanOrEqualTo(4.5),
        );
        expect(style.foregroundColor!.resolve({WidgetState.disabled}), isNull);
        expect(button.onPressed, isNotNull);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('a plain confirm keeps the theme primary', (tester) async {
      await _open(tester, (_) {});

      final context = tester.element(find.byType(AlertDialog));
      expect(_fill(tester), Theme.of(context).colorScheme.primary);
    });
  });

  group('focus', () {
    testWidgets('starts on Cancel when destructive', (tester) async {
      await _open(tester, (_) {}, destructive: true);

      expect(_focusedIn<TextButton>(), isNotNull);
    });

    testWidgets('starts on Confirm otherwise', (tester) async {
      await _open(tester, (_) {});

      expect(_focusedIn<FilledButton>(), isNotNull);
    });

    testWidgets('returns to the opener after close', (tester) async {
      await _open(tester, (_) {});
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(_focusedIn<ElevatedButton>(), isNotNull);
    });
  });

  group('layout', () {
    testWidgets('buttons keep 48 dp targets, also on macOS', (tester) async {
      for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        await _open(tester, (_) {});

        for (final finder in [
          find.widgetWithText(TextButton, 'Cancel'),
          find.widgetWithText(FilledButton, 'Confirm'),
        ]) {
          final rect = tester.getRect(finder);
          expect(rect.height, greaterThanOrEqualTo(48));
          expect(rect.width, greaterThanOrEqualTo(48));
        }
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('works in RTL', (tester) async {
      await _open(tester, (_) {}, direction: TextDirection.rtl);

      expect(tester.takeException(), isNull);
      final cancel = tester.getRect(find.text('Cancel'));
      final confirm = tester.getRect(find.text('Confirm'));
      expect(cancel.center.dx, lessThan(confirm.center.dx));
    });

    testWidgets('text scale 2 at 360 dp with a long message scrolls', (
      tester,
    ) async {
      await _open(
        tester,
        (_) {},
        scale: 2,
        size: const Size(360, 640),
        message: List.filled(
          40,
          'A long sentence about the consequences.',
        ).join(' '),
        destructive: true,
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      final rect = tester.getRect(find.byType(AlertDialog));
      expect(rect.bottom, lessThanOrEqualTo(640));
    });
  });

  testWidgets('is intrinsics-safe', (tester) async {
    await tester.pumpApp(
      themedHost(
        const IntrinsicWidth(
          child: ConfirmDialog(title: 'Delete?', message: 'Sure?'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
