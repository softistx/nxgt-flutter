import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/actions.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('shows its label and runs the action on press', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      host(AsyncButton(label: 'Save', onPressed: () async => calls++)),
    );

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.byType(AsyncButton));
    await tester.pump();
    expect(calls, 1);
  });

  testWidgets('is busy until the future completes and ignores presses', (
    tester,
  ) async {
    final completer = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      host(
        AsyncButton(
          label: 'Save',
          onPressed: () {
            calls++;
            return completer.future;
          },
        ),
      ),
    );

    await tester.tap(find.byType(AsyncButton));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(AsyncButton));
    await tester.pump();
    expect(calls, 1);

    completer.complete();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byType(AsyncButton));
    await tester.pump();
    expect(calls, 2);
  });

  testWidgets('becomes idle again when the action throws', (tester) async {
    await tester.pumpWidget(
      host(
        AsyncButton(
          label: 'Save',
          onPressed: () async => throw StateError('boom'),
        ),
      ),
    );

    await tester.tap(find.byType(AsyncButton));
    await tester.pump();

    expect(tester.takeException(), isA<StateError>());
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('loading overrides the tracked state', (tester) async {
    await tester.pumpWidget(
      host(AsyncButton(label: 'Save', loading: true, onPressed: () async {})),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('keeps the icon while idle and swaps it for the spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        AsyncButton(
          label: 'Save',
          icon: const Icon(Icons.save),
          onPressed: () async {},
        ),
      ),
    );
    expect(find.byIcon(Icons.save), findsOneWidget);

    await tester.pumpWidget(
      host(
        AsyncButton(
          label: 'Save',
          icon: const Icon(Icons.save),
          loading: true,
          onPressed: () async {},
        ),
      ),
    );
    expect(find.byIcon(Icons.save), findsNothing);
  });

  for (final variant in AsyncButtonVariant.values) {
    for (final withIcon in [false, true]) {
      testWidgets('builds the $variant variant (icon: $withIcon)', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            AsyncButton(
              label: 'Go',
              variant: variant,
              icon: withIcon ? const Icon(Icons.send) : null,
              onPressed: () async {},
            ),
          ),
        );

        expect(find.text('Go'), findsOneWidget);
      });
    }
  }

  group('semantics', () {
    testWidgets('is a labelled button with a 48 dp target', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(AsyncButton(label: 'Save', onPressed: () async {})),
      );

      expect(
        tester.getSemantics(find.text('Save')),
        matchesSemantics(
          label: 'Save',
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      final size = tester.getSize(find.byType(AsyncButton));
      expect(size.height, greaterThanOrEqualTo(48));
      handle.dispose();
    });

    testWidgets('announces Loading while busy and stays enabled', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(AsyncButton(label: 'Save', loading: true, onPressed: () async {})),
      );

      expect(
        tester.getSemantics(find.text('Save')),
        matchesSemantics(
          label: 'Save',
          value: 'Loading',
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('is disabled without an action', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const AsyncButton(label: 'Save', onPressed: null)),
      );

      expect(
        tester.getSemantics(find.text('Save')),
        matchesSemantics(label: 'Save', isButton: true, hasEnabledState: true),
      );
      handle.dispose();
    });
  });
}
