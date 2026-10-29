import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'StatCard looks right for each trend, light and dark',
    fileName: 'stat_card',
    builder: () => GoldenTestGroup(
      columns: 3,
      children: [
        for (final brightness in Brightness.values)
          for (final (trend, delta) in const [
            (StatTrend.up, '4 %'),
            (StatTrend.down, '2,5 %'),
            (StatTrend.flat, '0 %'),
          ])
            GoldenTestScenario(
              name: '${brightness.name} ${trend.name}',
              constraints: const BoxConstraints(maxWidth: 220),
              child: Theme(
                data: brightness == Brightness.light
                    ? ThemePresets.ocean.light()
                    : ThemePresets.ocean.dark(),
                child: Material(
                  child: StatCard(
                    label: 'Revenue',
                    value: '1 200',
                    delta: delta,
                    trend: trend,
                    icon: Icons.payments_outlined,
                    onTap: trend == StatTrend.flat ? () {} : null,
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}
