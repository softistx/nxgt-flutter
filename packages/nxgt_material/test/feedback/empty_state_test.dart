import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/feedback.dart';

import '../support/host.dart';

void main() {
  testWidgets('shows the localized default copy and an inbox icon', (
    tester,
  ) async {
    await tester.pumpApp(themedHost(const EmptyState()));

    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('There is nothing to show for now.'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('speaks French', (tester) async {
    await tester.pumpApp(
      themedHost(const EmptyState(), locale: const Locale('fr')),
    );

    expect(find.text('Rien pour l’instant'), findsOneWidget);
  });

  testWidgets('takes its own copy, icon and action', (tester) async {
    var pressed = 0;
    await tester.pumpApp(
      themedHost(
        EmptyState(
          title: 'No invoices',
          message: 'Create the first one.',
          icon: const Icon(Icons.receipt_long),
          action: FilledButton(
            onPressed: () => pressed++,
            child: const Text('New invoice'),
          ),
        ),
      ),
    );

    expect(find.text('No invoices'), findsOneWidget);
    expect(find.text('Create the first one.'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    await tester.tap(find.text('New invoice'));
    expect(pressed, 1);
  });

  group('semantics', () {
    testWidgets('a live region with a heading, the icon hidden', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(themedHost(const EmptyState()));

      expect(
        tester.getSemantics(find.text('Nothing here yet')),
        isSemantics(
          label: 'Nothing here yet\nThere is nothing to show for now.',
          isHeader: true,
          isLiveRegion: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('the action is a 48 dp button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        themedHost(
          EmptyState(
            action: FilledButton(onPressed: () {}, child: const Text('Add')),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('Add')),
        isSemantics(label: 'Add', isButton: true),
      );
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });
}
