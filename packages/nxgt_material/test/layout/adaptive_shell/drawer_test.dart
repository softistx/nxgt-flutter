import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import 'adaptive_shell_harness.dart';

void main() {
  group('drawer', () {
    testWidgets('opens from the menu button and closes from its own', (
      tester,
    ) async {
      await pumpShell(
        tester,
        400,
        buildShell(compact: CompactNavigation.drawer),
      );
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);

      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDrawer), findsOneWidget);

      await tester.tap(find.byTooltip('Close navigation'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('picking a destination selects it and closes the drawer', (
      tester,
    ) async {
      final picked = <int>[];
      await pumpShell(
        tester,
        400,
        buildShell(compact: CompactNavigation.drawer, onSelected: picked.add),
      );
      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(picked, [2]);
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('the open and close labels are localized', (tester) async {
      await pumpShell(
        tester,
        400,
        buildShell(compact: CompactNavigation.drawer),
        locale: const Locale('fr'),
      );
      await tester.tap(find.byTooltip('Ouvrir la navigation'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Fermer la navigation'), findsOneWidget);
    });

    testWidgets('the menu button is a 48 dp button with its label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpShell(
        tester,
        400,
        buildShell(compact: CompactNavigation.drawer),
      );
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(tooltip: 'Open navigation', isButton: true),
      );
      expect(tester.getSize(find.byType(IconButton)), const Size(48, 48));
      handle.dispose();
    });

    testWidgets('a wider window leaves the drawer for a rail', (tester) async {
      await pumpShell(
        tester,
        700,
        buildShell(compact: CompactNavigation.drawer),
      );
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byTooltip('Open navigation'), findsNothing);
    });
  });

  group('drawer button', () {
    for (final width in [700.0, 1000.0]) {
      testWidgets('no drawer button beside the navigation at $width dp', (
        tester,
      ) async {
        await pumpShell(
          tester,
          width,
          buildShell(
            compact: CompactNavigation.drawer,
            title: const Text('Acme'),
          ),
        );
        expect(find.byType(DrawerButton), findsNothing);
        expect(find.byTooltip('Open navigation'), findsNothing);
        expect(find.byIcon(Icons.menu), findsNothing);
      });
    }

    testWidgets('the menu button is there on a compact window', (tester) async {
      await pumpShell(
        tester,
        400,
        buildShell(
          compact: CompactNavigation.drawer,
          title: const Text('Acme'),
        ),
      );
      expect(find.byTooltip('Open navigation'), findsOneWidget);
    });
  });
}
