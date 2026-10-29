import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: StatCard, path: '[Display]')
/// The default use-case of [StatCard].
Widget buildStatCardDefault(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 240,
      child: StatCard(
        label: context.knobs.string(label: 'Label', initialValue: 'Revenue'),
        value: context.knobs.string(label: 'Value', initialValue: '1 200'),
        delta: context.knobs.string(label: 'Delta', initialValue: '4 %'),
        trend: context.knobs.object.dropdown(
          label: 'Trend',
          initialOption: StatTrend.up,
          options: StatTrend.values,
          labelBuilder: (trend) => trend?.name ?? '',
        ),
        positiveIsUp: context.knobs.boolean(
          label: 'Positive is up',
          initialValue: true,
        ),
        icon: Icons.payments_outlined,
        onTap: context.knobs.boolean(label: 'Tappable') ? () {} : null,
      ),
    ),
  );
}
