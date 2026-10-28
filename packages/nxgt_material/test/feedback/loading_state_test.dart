import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/feedback.dart';

import '../support/host.dart';

void main() {
  testWidgets('shows a spinner and the localized caption', (tester) async {
    await tester.pumpApp(themedHost(const LoadingState()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);
  });

  testWidgets('takes its own caption', (tester) async {
    await tester.pumpApp(
      themedHost(const LoadingState(message: 'Fetching invoices')),
    );

    expect(find.text('Fetching invoices'), findsOneWidget);
  });

  testWidgets('speaks French', (tester) async {
    await tester.pumpApp(
      themedHost(const LoadingState(), locale: const Locale('fr')),
    );

    expect(find.text('Chargement'), findsOneWidget);
  });

  testWidgets('replaces the spinner with a static icon under reduced motion', (
    tester,
  ) async {
    await tester.pumpApp(
      themedHost(const LoadingState(), disableAnimations: true),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);
  });

  testWidgets('semantics: a live region saying Loading, spinner hidden', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(const LoadingState()));

    expect(
      tester.getSemantics(find.text('Loading')),
      isSemantics(label: 'Loading', isLiveRegion: true),
    );
    handle.dispose();
  });
}
