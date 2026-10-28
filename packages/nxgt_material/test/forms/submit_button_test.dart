import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/forms.dart';

import '../support/host.dart';

void main() {
  late GlobalKey<FormState> key;
  setUp(() => key = GlobalKey<FormState>());

  Future<void> pump(
    WidgetTester tester, {
    required Future<void> Function()? onSubmit,
    String initial = 'ada@example.com',
    void Function(String?)? onSaved,
  }) async {
    await tester.pumpWidget(
      formHost([
        EmailField(label: 'Email', initialValue: initial, onSaved: onSaved),
        SubmitButton(label: 'Send', onSubmit: onSubmit),
      ], formKey: key),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('saves a valid form, then submits', (tester) async {
    final order = <String>[];
    await pump(
      tester,
      onSaved: (v) => order.add('saved $v'),
      onSubmit: () async => order.add('submitted'),
    );

    await tester.tap(find.text('Send'));
    await tester.pump();

    expect(order, ['saved ada@example.com', 'submitted']);
  });

  testWidgets('shows the errors and submits nothing when invalid', (
    tester,
  ) async {
    var submitted = false;
    await pump(tester, initial: 'nope', onSubmit: () async => submitted = true);

    await tester.tap(find.text('Send'));
    await tester.pump();

    expect(submitted, isFalse);
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('focuses the first invalid field, in tree order', (tester) async {
    await tester.pumpWidget(
      formHost([
        const EmailField(label: 'Ok', initialValue: 'ada@example.com'),
        const EmailField(label: 'First bad', initialValue: 'nope'),
        const EmailField(label: 'Second bad', initialValue: 'nope too'),
        SubmitButton(label: 'Send', onSubmit: () async {}),
      ], formKey: key),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    final focused = FocusManager.instance.primaryFocus!;
    expect(
      find.ancestor(
        of: find.byWidgetPredicate(
          (w) => w is EditableText && w.focusNode == focused,
        ),
        matching: find.widgetWithText(TextFormField, 'First bad'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('is busy until the submit completes and ignores a second press', (
    tester,
  ) async {
    final done = Completer<void>();
    var calls = 0;
    await pump(
      tester,
      onSubmit: () {
        calls++;
        return done.future;
      },
    );

    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(calls, 1);

    done.complete();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('is disabled without onSubmit', (tester) async {
    await pump(tester, onSubmit: null);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('outside a Form it reports a FlutterError', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubmitButton(label: 'Send', onSubmit: () async {}),
        ),
      ),
    );

    await tester.tap(find.text('Send'));
    await tester.pump();

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('SubmitButton was used outside a Form'));
  });

  group('semantics', () {
    testWidgets('is a labelled 48 dp button', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, onSubmit: () async {});

      expect(
        tester.getSemantics(find.text('Send')),
        matchesSemantics(
          label: 'Send',
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSize(find.byType(SubmitButton)).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });

    testWidgets('announces Loading while submitting', (tester) async {
      final handle = tester.ensureSemantics();
      final done = Completer<void>();
      await pump(tester, onSubmit: () => done.future);

      await tester.tap(find.text('Send'));
      await tester.pump();

      expect(
        tester.getSemantics(find.text('Send')),
        isSemantics(label: 'Send', value: 'Loading', isLiveRegion: true),
      );
      done.complete();
      await tester.pump();
      handle.dispose();
    });
  });
}
