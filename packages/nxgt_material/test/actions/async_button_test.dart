import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/actions.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  group('48 dp target on every platform', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
      for (final variant in AsyncButtonVariant.values) {
        for (final loading in [false, true]) {
          testWidgets('${variant.name}, loading $loading, $platform', (
            tester,
          ) async {
            debugDefaultTargetPlatformOverride = platform;
            try {
              await tester.pumpWidget(
                host(
                  AsyncButton(
                    label: 'Go',
                    variant: variant,
                    loading: loading,
                    onPressed: () async {},
                  ),
                ),
              );
              expect(
                tester.getSize(find.byType(AsyncButton)).height,
                greaterThanOrEqualTo(48),
              );
            } finally {
              debugDefaultTargetPlatformOverride = null;
            }
          });
        }
      }
    }
  });

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

    testWidgets(
      'announces Loading in a live region while busy and stays enabled',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            AsyncButton(label: 'Save', loading: true, onPressed: () async {}),
          ),
        );

        expect(
          tester.getSemantics(find.text('Save')),
          matchesSemantics(
            label: 'Save',
            value: 'Loading',
            isLiveRegion: true,
            isButton: true,
            isEnabled: true,
            isFocusable: true,
            hasEnabledState: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );
        expect(
          tester.getSize(find.byType(AsyncButton)).height,
          greaterThanOrEqualTo(48),
        );
        handle.dispose();
      },
    );

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

  group('autofocus', () {
    bool focused(WidgetTester tester, Type button) =>
        FocusManager.instance.primaryFocus?.context
                ?.findAncestorWidgetOfExactType<AsyncButton>() !=
            null ||
        FocusManager.instance.primaryFocus?.context
                ?.findAncestorWidgetOfExactType<FilledButton>() !=
            null;

    testWidgets('takes the focus, without an icon', (tester) async {
      await tester.pumpWidget(
        host(
          AsyncButton(label: 'Save', autofocus: true, onPressed: () async {}),
        ),
      );
      await tester.pump();
      expect(focused(tester, FilledButton), isTrue);
    });

    testWidgets('takes the focus, with an icon', (tester) async {
      await tester.pumpWidget(
        host(
          AsyncButton(
            label: 'Save',
            icon: const Icon(Icons.save),
            autofocus: true,
            onPressed: () async {},
          ),
        ),
      );
      await tester.pump();
      expect(focused(tester, FilledButton), isTrue);
    });

    testWidgets('does not take the focus by default', (tester) async {
      await tester.pumpWidget(
        host(AsyncButton(label: 'Save', onPressed: () async {})),
      );
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<FilledButton>(),
        isNull,
      );
    });
  });
}
