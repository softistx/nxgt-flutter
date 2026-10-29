import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/display.dart';

import '../support/host.dart';

void main() {
  Widget badge(int count, {int max = 99, String? label}) => CountBadge(
    count: count,
    max: max,
    semanticLabel: label,
    child: const Icon(Icons.mail_outline),
  );

  testWidgets('CountBadge shows the count', (tester) async {
    await tester.pumpApp(themedHost(badge(7)));

    expect(find.text('7'), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline), findsOneWidget);
  });

  testWidgets('CountBadge caps at 99+ by default', (tester) async {
    await tester.pumpApp(themedHost(badge(120)));

    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('CountBadge honours max', (tester) async {
    await tester.pumpApp(themedHost(badge(12, max: 9)));

    expect(find.text('9+'), findsOneWidget);
  });

  testWidgets('CountBadge is hidden at 0 and keeps its child', (tester) async {
    await tester.pumpApp(themedHost(badge(0)));

    expect(find.text('0'), findsNothing);
    expect(find.byIcon(Icons.mail_outline), findsOneWidget);
  });

  testWidgets('CountBadge speaks the label and the real count', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(badge(120, label: 'Inbox')));

    expect(find.bySemanticsLabel('Inbox, 120 items'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('CountBadge uses the singular for 1', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(badge(1, label: 'Inbox')));

    expect(find.bySemanticsLabel('Inbox, 1 item'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('CountBadge speaks French plurals', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      themedHost(badge(3, label: 'Messages'), locale: const Locale('fr')),
    );

    expect(find.bySemanticsLabel('Messages, 3 éléments'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('CountBadge says only the label at 0', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(badge(0, label: 'Inbox')));

    expect(find.bySemanticsLabel('Inbox'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('CountBadge without a label keeps an interactive child', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      themedHost(
        CountBadge(
          count: 0,
          child: IconButton(
            tooltip: 'Open inbox',
            onPressed: () {},
            icon: const Icon(Icons.mail_outline),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(IconButton)),
      isSemantics(isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  test('CountBadge asserts a negative count and a non-positive max', () {
    expect(
      () => CountBadge(count: -1, child: const SizedBox()),
      throwsAssertionError,
    );
    expect(
      () => CountBadge(count: 1, max: 0, child: const SizedBox()),
      throwsAssertionError,
    );
  });
}
