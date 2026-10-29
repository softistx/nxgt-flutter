import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'adaptive_shell_harness.dart';

void main() {
  group('keyboard and pointer', () {
    for (final width in [400.0, 700.0, 1000.0]) {
      testWidgets('Tab walks the destinations and Enter selects at $width', (
        tester,
      ) async {
        final picked = <int>[];
        await pumpShell(tester, width, buildShell(onSelected: picked.add));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(picked, [1]);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(picked, [1, 2]);
      });
    }

    testWidgets('Shift+Tab goes back through the destinations', (tester) async {
      final picked = <int>[];
      await pumpShell(tester, 400, buildShell(onSelected: picked.add));
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      }
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(picked, [1]);
    });

    for (final width in [400.0, 700.0, 1000.0]) {
      testWidgets('a mouse pointer highlights the destination at $width', (
        tester,
      ) async {
        await pumpShell(tester, width, buildShell());
        final settings = find.text('Settings').first;
        final ink = Material.of(tester.element(settings)) as RenderObject;
        final before = inkDraws(ink);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(settings));
        await tester.pumpAndSettle();
        expect(inkDraws(ink), greaterThan(before));
      });
    }
  });

  group('keyboard in French', () {
    testWidgets('Space selects and the region is labelled in French', (
      tester,
    ) async {
      final picked = <int>[];
      await pumpShell(
        tester,
        400,
        buildShell(onSelected: picked.add),
        locale: const Locale('fr'),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(picked, [1]);
    });
  });
}
