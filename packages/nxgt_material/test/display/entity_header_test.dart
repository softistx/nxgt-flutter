import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';

import '../support/host.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget header, {
  double width = 360,
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpApp(
    themedHost(
      Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 800),
            textScaler: TextScaler.linear(scale),
          ),
          child: SingleChildScrollView(child: header),
        ),
      ),
    ),
  );
}

void main() {
  var edited = 0;
  var deleted = 0;
  setUp(() => edited = deleted = 0);

  EntityHeader header({String title = 'Ada Lovelace'}) => EntityHeader(
    title: title,
    subtitle: 'ada@example.com',
    leading: const CircleAvatar(child: Text('A')),
    status: const Text('Active'),
    actions: [
      EntityAction(label: 'Edit', icon: Icons.edit, onPressed: () => edited++),
      EntityAction(
        label: 'Delete',
        icon: Icons.delete_outline,
        destructive: true,
        onPressed: () => deleted++,
      ),
    ],
  );

  testWidgets('the title is a semantics header', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, header());

    final node = tester.getSemantics(find.text('Ada Lovelace'));
    expect(node.flagsCollection.isHeader, isTrue);
    expect(find.text('ada@example.com'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    handle.dispose();
  });

  group('compact', () {
    testWidgets('folds the actions into a menu that fires them', (
      tester,
    ) async {
      await _pump(tester, header());

      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byTooltip('More options'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(edited, 1);
      expect(deleted, 0);
    });

    testWidgets('the overflow button is a 48 dp target', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, header());

      final rect = tester.getSemantics(find.byTooltip('More options')).rect;
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
      handle.dispose();
    });

    testWidgets('draws no menu without actions', (tester) async {
      await _pump(tester, const EntityHeader(title: 'Ada'));

      expect(find.byTooltip('More options'), findsNothing);
    });

    testWidgets('the destructive item uses the error tone', (tester) async {
      await _pump(tester, header());
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();

      final item = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Delete'),
      );
      final context = tester.element(find.byType(EntityHeader));
      final error = context.tones.error;
      expect(item.style?.foregroundColor?.resolve({}), error.onContainer);
      expect(item.style?.backgroundColor?.resolve({}), error.container);
    });
  });

  group('medium', () {
    testWidgets('shows the actions as buttons that fire', (tester) async {
      await _pump(tester, header(), width: 640);

      expect(find.byTooltip('More options'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Edit'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      expect(deleted, 1);
      expect(edited, 0);
    });

    testWidgets('buttons keep 48 dp targets', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, header(), width: 640);

      for (final label in ['Edit', 'Delete']) {
        final rect = tester.getSemantics(find.text(label)).rect;
        expect(rect.height, greaterThanOrEqualTo(48));
      }
      handle.dispose();
    });

    testWidgets('the destructive button uses the error tone', (tester) async {
      await _pump(tester, header(), width: 640);

      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Delete'),
      );
      final context = tester.element(find.byType(EntityHeader));
      final error = context.tones.error;
      expect(button.style?.foregroundColor?.resolve({}), error.onContainer);
      expect(button.style?.backgroundColor?.resolve({}), error.container);
      final plain = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Edit'),
      );
      expect(plain.style, isNull);
    });

    testWidgets('folds into the menu above 1.5x text', (tester) async {
      await _pump(tester, header(), width: 640, scale: 2);

      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byTooltip('More options'), findsOneWidget);
    });
  });

  testWidgets('mirrors in right-to-left', (tester) async {
    Future<double> avatarX(TextDirection direction) async {
      await _pump(tester, header(), width: 640, direction: direction);
      return tester.getCenter(find.byType(CircleAvatar)).dx;
    }

    final ltr = await avatarX(TextDirection.ltr);
    final rtl = await avatarX(TextDirection.rtl);
    expect(ltr, lessThan(320));
    expect(rtl, greaterThan(320));
    final edit = tester.getCenter(find.widgetWithText(OutlinedButton, 'Edit'));
    expect(edit.dx, lessThan(320));
  });

  for (final width in [360.0, 600.0]) {
    testWidgets('a long title wraps at 2x text, $width dp', (tester) async {
      await _pump(
        tester,
        header(title: 'A very long entity name ' * 6),
        width: width,
        scale: 2,
      );

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a disabled action stays in the menu', (tester) async {
    await _pump(
      tester,
      const EntityHeader(
        title: 'Ada',
        actions: [EntityAction(label: 'Edit', onPressed: null)],
      ),
    );
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    final item = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
    expect(item.onPressed, isNull);
  });
}
