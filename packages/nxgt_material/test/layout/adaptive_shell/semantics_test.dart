import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'adaptive_shell_harness.dart';

void main() {
  group('semantics', () {
    for (final width in [400.0, 700.0, 1000.0]) {
      testWidgets('the selected destination is selected at $width dp', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpShell(tester, width, buildShell(selected: 1));
        expect(
          tester.getSemantics(find.text('Inbox').first),
          isSemantics(
            label: 'Inbox\nTab 2 of 3',
            isSelected: true,
            hasSelectedState: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );
        expect(
          tester.getSemantics(find.text('Home').first),
          isSemantics(
            label: 'Home\nTab 1 of 3',
            hasSelectedState: true,
            isFocusable: true,
            hasTapAction: true,
          ),
        );
        handle.dispose();
      });
    }

    testWidgets('destinations are at least 48 dp', (tester) async {
      for (final width in [400.0, 700.0, 1000.0]) {
        await pumpShell(tester, width, buildShell());
        for (final label in ['Home', 'Inbox', 'Settings']) {
          final box = tester.getSemantics(find.text(label).first).rect;
          expect(box.height, greaterThanOrEqualTo(48), reason: '$label $width');
          expect(box.width, greaterThanOrEqualTo(48), reason: '$label $width');
        }
      }
    });

    testWidgets('the navigation is a labelled region, localized', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpShell(tester, 400, buildShell());
      expect(find.bySemanticsLabel('Navigation'), findsOneWidget);
      await pumpShell(tester, 400, buildShell(), locale: const Locale('fr'));
      expect(find.bySemanticsLabel('Navigation'), findsOneWidget);
      handle.dispose();
    });
  });
}
