import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/layout.dart';

Widget _grid(double width, double height) => SizedBox(
  width: width,
  height: height,
  child: ResponsiveGrid(
    minItemWidth: 160,
    children: [
      for (var i = 0; i < 6; i++)
        Card(
          child: SizedBox(height: 64, child: Center(child: Text('Tile $i'))),
        ),
    ],
  ),
);

Future<void> main() async {
  await goldenTest(
    'ResponsiveGrid gains columns with the width',
    fileName: 'responsive_grid',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(name: 'compact', child: _grid(360, 240)),
        GoldenTestScenario(name: 'expanded', child: _grid(1000, 100)),
      ],
    ),
  );
}
