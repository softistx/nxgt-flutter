import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import '../support/host.dart';

Future<void> _pump(WidgetTester tester, double width, Widget body) async {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpApp(themedHost(body));
}

void main() {
  const key = Key('content');
  const body = PageBody(
    child: SizedBox(key: key, height: 40, width: double.infinity),
  );

  final gutters = <double, double>{
    400: 16,
    700: 24,
    900: 24,
    1300: 32,
    1700: 32,
  };
  for (final MapEntry(key: width, value: gutter) in gutters.entries) {
    testWidgets('uses a $gutter dp gutter at $width dp', (tester) async {
      await _pump(tester, width, body);
      final box = tester.getRect(find.byKey(key));
      final available = width < 1200 ? width : 1200.0;
      final left = (width - available) / 2 + gutter;
      expect(box.left, left);
      expect(box.width, available - 2 * gutter);
    });
  }

  testWidgets('is centred and no wider than maxWidth', (tester) async {
    await _pump(
      tester,
      1700,
      const PageBody(
        maxWidth: 600,
        child: SizedBox(key: key, height: 40, width: double.infinity),
      ),
    );
    final box = tester.getRect(find.byKey(key));
    expect(box.width, 600 - 2 * 32);
    expect(box.center.dx, 850);
  });

  testWidgets('takes a gutter of its own', (tester) async {
    await _pump(
      tester,
      400,
      const PageBody(
        gutter: 4,
        child: SizedBox(key: key, height: 40, width: double.infinity),
      ),
    );
    expect(tester.getRect(find.byKey(key)).left, 4);
  });

  testWidgets('mirrors its gutters in a right-to-left locale', (tester) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      themedHost(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: PageBody(
            gutter: 10,
            child: SizedBox(key: key, height: 40, width: double.infinity),
          ),
        ),
      ),
    );
    final box = tester.getRect(find.byKey(key));
    expect(box.left, 10);
    expect(box.right, 390);
  });

  testWidgets('adds no semantics of its own', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, 400, const PageBody(child: Text('Hello')));
    expect(
      tester.getSemantics(find.text('Hello')),
      isSemantics(label: 'Hello'),
    );
    handle.dispose();
  });
}
