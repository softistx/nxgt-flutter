import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/actions.dart';

void main() {
  Widget host({VoidCallback? onPressed, Widget? icon, String? menuTooltip}) =>
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SplitButton(
              label: 'Save',
              icon: icon,
              menuTooltip: menuTooltip,
              onPressed: onPressed,
              menuChildren: [
                MenuItemButton(onPressed: () {}, child: const Text('Draft')),
              ],
            ),
          ),
        ),
      );

  testWidgets('the main part runs the main action', (tester) async {
    var calls = 0;
    await tester.pumpWidget(host(onPressed: () => calls++));

    await tester.tap(find.text('Save'));
    expect(calls, 1);
  });

  testWidgets('shows the icon before the label', (tester) async {
    await tester.pumpWidget(
      host(onPressed: () {}, icon: const Icon(Icons.save)),
    );

    expect(find.byIcon(Icons.save), findsOneWidget);
  });

  testWidgets('the arrow opens and closes the menu', (tester) async {
    await tester.pumpWidget(host(onPressed: () {}));
    expect(find.text('Draft'), findsNothing);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    expect(find.text('Draft'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    expect(find.text('Draft'), findsNothing);
  });

  testWidgets('the menu works when the main action is null', (tester) async {
    await tester.pumpWidget(host());

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('the arrow tooltip can be overridden', (tester) async {
    await tester.pumpWidget(host(menuTooltip: 'Other saves'));

    expect(find.byTooltip('Other saves'), findsOneWidget);
  });

  group('semantics', () {
    testWidgets('two labelled buttons, each a 48 dp target', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(onPressed: () {}));

      expect(
        tester.getSemantics(find.byType(FilledButton)),
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
      expect(
        tester.getSemantics(find.byType(IconButton)),
        matchesSemantics(
          tooltip: 'More options',
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasEnabledState: true,
          hasExpandedState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      final main = tester.getSize(find.byType(FilledButton));
      expect(main.height, greaterThanOrEqualTo(48));
      expect(main.width, greaterThanOrEqualTo(48));
      final arrow = tester.getSize(find.byType(IconButton));
      expect(arrow.width, greaterThanOrEqualTo(48));
      expect(arrow.height, greaterThanOrEqualTo(48));
      handle.dispose();
    });

    testWidgets('a null main action disables the main part only', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host());

      expect(
        tester.getSemantics(find.byType(FilledButton)),
        matchesSemantics(label: 'Save', isButton: true, hasEnabledState: true),
      );
      expect(
        tester.getSemantics(find.byType(IconButton)),
        matchesSemantics(
          tooltip: 'More options',
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasEnabledState: true,
          hasExpandedState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('the arrow reports expanded when the menu is open', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(onPressed: () {}));

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(IconButton)),
        matchesSemantics(
          tooltip: 'More options',
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasEnabledState: true,
          hasExpandedState: true,
          isExpanded: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });
  });
}
