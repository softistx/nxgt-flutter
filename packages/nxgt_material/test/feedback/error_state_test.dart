import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/actions.dart';
import 'package:nxgt_material/feedback.dart';

import '../support/host.dart';

void main() {
  testWidgets(
    'shows the localized default copy and no retry without a handler',
    (tester) async {
      await tester.pumpApp(themedHost(const ErrorState()));

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(
        find.text('An error occurred. Try again in a moment.'),
        findsOneWidget,
      );
      expect(find.byType(AsyncButton), findsNothing);
    },
  );

  testWidgets('speaks French', (tester) async {
    await tester.pumpApp(
      themedHost(ErrorState(onRetry: () async {}), locale: const Locale('fr')),
    );

    expect(find.text('Une erreur est survenue'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('Retry is an AsyncButton: busy until the future completes', (
    tester,
  ) async {
    final done = Completer<void>();
    var calls = 0;
    await tester.pumpApp(
      themedHost(
        ErrorState(
          onRetry: () {
            calls++;
            return done.future;
          },
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    done.complete();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('takes its own copy and retry label', (tester) async {
    await tester.pumpApp(
      themedHost(
        ErrorState(
          title: 'Offline',
          message: 'Check the connection.',
          retryLabel: 'Reconnect',
          onRetry: () async {},
        ),
      ),
    );

    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Check the connection.'), findsOneWidget);
    expect(find.text('Reconnect'), findsOneWidget);
  });

  group('semantics', () {
    testWidgets('a live region with a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(themedHost(const ErrorState()));

      expect(
        tester.getSemantics(find.text('Something went wrong')),
        isSemantics(
          label:
              'Something went wrong\n'
              'An error occurred. Try again in a moment.',
          isHeader: true,
          isLiveRegion: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('Retry is a labelled button of at least 48 dp', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(themedHost(ErrorState(onRetry: () async {})));

      expect(
        tester.getSemantics(find.text('Retry')),
        isSemantics(label: 'Retry', isButton: true, isEnabled: true),
      );
      expect(
        tester.getSize(find.byType(AsyncButton)).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });
}
