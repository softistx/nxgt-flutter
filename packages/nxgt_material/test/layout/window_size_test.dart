import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import '../support/host.dart';

void main() {
  group('WindowSize.fromWidth', () {
    final cases = <double, WindowSize>{
      0: WindowSize.compact,
      599.9: WindowSize.compact,
      600: WindowSize.medium,
      839.9: WindowSize.medium,
      840: WindowSize.expanded,
      1199.9: WindowSize.expanded,
      1200: WindowSize.large,
      1599.9: WindowSize.large,
      1600: WindowSize.extraLarge,
      3000: WindowSize.extraLarge,
    };
    for (final MapEntry(key: width, value: expected) in cases.entries) {
      test('$width is ${expected.name}', () {
        expect(WindowSize.fromWidth(width), expected);
      });
    }
  });

  test('breakpoints keep the Material 3 values of @nxgt/material', () {
    expect(Breakpoints.medium, 600);
    expect(Breakpoints.expanded, 840);
    expect(Breakpoints.large, 1200);
    expect(Breakpoints.extraLarge, 1600);
    expect(Breakpoints.singlePane, 648);
    expect(WindowSize.expanded.minWidth, Breakpoints.expanded);
  });

  test('isAtLeast compares the classes in order', () {
    expect(WindowSize.large.isAtLeast(WindowSize.expanded), isTrue);
    expect(WindowSize.expanded.isAtLeast(WindowSize.expanded), isTrue);
    expect(WindowSize.medium.isAtLeast(WindowSize.expanded), isFalse);
  });

  group('context.windowSize', () {
    final widths = <double, WindowSize>{
      400: WindowSize.compact,
      700: WindowSize.medium,
      900: WindowSize.expanded,
      1300: WindowSize.large,
      1700: WindowSize.extraLarge,
    };
    for (final MapEntry(key: width, value: expected) in widths.entries) {
      testWidgets('reads ${expected.name} at $width dp', (tester) async {
        tester.view
          ..physicalSize = Size(width, 800)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        WindowSize? seen;
        await tester.pumpApp(
          themedHost(
            Builder(
              builder: (context) {
                seen = context.windowSize;
                return const SizedBox();
              },
            ),
          ),
        );
        expect(seen, expected);
      });
    }

    testWidgets('changes when the window is resized', (tester) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final seen = <WindowSize>[];
      await tester.pumpApp(
        themedHost(
          Builder(
            builder: (context) {
              seen.add(context.windowSize);
              return const SizedBox();
            },
          ),
        ),
      );
      tester.view.physicalSize = const Size(900, 800);
      await tester.pump();
      expect(seen.first, WindowSize.compact);
      expect(seen.last, WindowSize.expanded);
    });
  });
}
