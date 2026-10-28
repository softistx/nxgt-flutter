import 'package:flutter/material.dart';
import 'package:nxgt_material/layout.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ResponsiveGrid, path: '[Layout]')
/// The default use-case of [ResponsiveGrid].
Widget buildResponsiveGridDefault(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: ResponsiveGrid(
      minItemWidth: context.knobs.double.slider(
        label: 'Min item width',
        initialValue: 200,
        min: 100,
        max: 400,
      ),
      spacing: context.knobs.double.slider(
        label: 'Spacing',
        initialValue: 8,
        max: 32,
      ),
      children: [
        for (var i = 1; i <= 8; i++)
          Card(
            child: SizedBox(height: 80, child: Center(child: Text('Tile $i'))),
          ),
      ],
    ),
  );
}
