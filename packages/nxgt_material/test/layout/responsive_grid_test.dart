import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import '../support/host.dart';

Widget _grid({double minItemWidth = 200, double spacing = 10, int count = 6}) =>
    ResponsiveGrid(
      minItemWidth: minItemWidth,
      spacing: spacing,
      children: [
        for (var i = 0; i < count; i++)
          SizedBox(key: ValueKey(i), height: 50, child: Text('Tile $i')),
      ],
    );

Future<void> _pump(WidgetTester tester, double width, Widget grid) async {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpApp(
    themedHost(Align(alignment: Alignment.topLeft, child: grid)),
  );
}

int _columns(WidgetTester tester, int count) {
  final tops = {
    for (var i = 0; i < count; i++)
      tester.getTopLeft(find.byKey(ValueKey(i))).dy,
  };
  return count ~/ tops.length;
}

void main() {
  test('columnsFor counts the tiles that fit with their spacing', () {
    expect(ResponsiveGrid.columnsFor(199, 200, 10), 1);
    expect(ResponsiveGrid.columnsFor(410, 200, 10), 2);
    expect(ResponsiveGrid.columnsFor(409, 200, 10), 1);
    expect(ResponsiveGrid.columnsFor(double.infinity, 200, 10), 1);
  });

  final widths = <double, int>{200: 1, 420: 2, 640: 3, 860: 4};
  for (final MapEntry(key: width, value: columns) in widths.entries) {
    testWidgets('has $columns column(s) at $width dp', (tester) async {
      await _pump(tester, width, _grid(count: 12));
      expect(_columns(tester, 12), columns);
    });
  }

  testWidgets('tiles share the width equally', (tester) async {
    await _pump(tester, 430, _grid());
    expect(tester.getSize(find.byKey(const ValueKey(0))).width, 210);
    expect(tester.getTopLeft(find.byKey(const ValueKey(1))).dx, 220);
  });

  testWidgets('spaces the rows by spacing', (tester) async {
    await _pump(tester, 430, _grid());
    expect(tester.getTopLeft(find.byKey(const ValueKey(2))).dy, 60);
  });

  testWidgets('sits in a scroll view without an unbounded width error', (
    tester,
  ) async {
    await tester.pumpApp(
      themedHost(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _grid(count: 3),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const ValueKey(0))).width, 200);
  });

  testWidgets('adds no semantics: every tile keeps its own', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, 430, _grid(count: 2));
    expect(
      tester.getSemantics(find.text('Tile 0')),
      isSemantics(label: 'Tile 0'),
    );
    expect(
      tester.getSemantics(find.text('Tile 1')),
      isSemantics(label: 'Tile 1'),
    );
    handle.dispose();
  });
}
