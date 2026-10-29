import 'package:flutter/material.dart';
import 'package:nxgt_material/src/actions/copy_button.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/layout/window_size.dart';

/// One row of a [DescriptionList]: a [label], its [value] and whether the
/// value can be copied.
@immutable
class DescriptionItem {
  /// Creates a DescriptionItem.
  const new({required this.label, required this.value, this.copyable = false});

  /// What the row describes, such as "Invoice".
  final String label;

  /// The value, already formatted, such as "INV-2026-0042".
  final String value;

  /// Whether a `CopyButton` follows the value. Its label names the item
  /// ("Copy Invoice").
  final bool copyable;
}

/// Labels and values as rows: side by side from the medium window size up,
/// stacked on compact.
///
/// Use it for the details of a record (an invoice, a user, an order). With
/// `copyable: true` a [CopyButton] follows the value. Each row is read as
/// "label, value" in order; a label is not a heading. Insets and alignment
/// follow the text direction. It is not a `DataTable` (many rows, many
/// columns) nor a `ListTile` (a tappable row).
class DescriptionList extends StatelessWidget {
  /// Creates a DescriptionList.
  const new({required this.items, super.key});

  /// The rows, in reading order. An empty list draws nothing.
  final List<DescriptionItem> items;

  @override
  Widget build(BuildContext context) {
    final sideBySide = _sideBySide(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: sideBySide ? 8 : 16,
      children: [
        for (final item in items) _row(context, item, sideBySide: sideBySide),
      ],
    );
  }

  /// Medium window and up, unless the text is scaled past 1.5: the fixed label
  /// column would then leave the value too little width.
  bool _sideBySide(BuildContext context) =>
      context.windowSize.isAtLeast(WindowSize.medium) &&
      MediaQuery.textScalerOf(context).scale(16) <= 24;

  Widget _row(
    BuildContext context,
    DescriptionItem item, {
    required bool sideBySide,
  }) {
    final copy = item.copyable
        ? CopyButton(
            value: item.value,
            tooltip: context.materialL10n.actionsCopyItem(item.label),
          )
        : null;
    return Semantics(
      container: true,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              label: '${item.label}, ${item.value}',
              excludeSemantics: true,
              child: sideBySide
                  ? _wide(context, item)
                  : _stacked(context, item),
            ),
          ),
          ?copy,
        ],
      ),
    );
  }

  Widget _wide(BuildContext context, DescriptionItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      spacing: 16,
      children: [
        SizedBox(width: 176, child: _label(context, item)),
        Expanded(child: _value(context, item)),
      ],
    );
  }

  Widget _stacked(BuildContext context, DescriptionItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [_label(context, item), _value(context, item)],
    );
  }

  Widget _label(BuildContext context, DescriptionItem item) {
    final theme = Theme.of(context);
    return Text(
      item.label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _value(BuildContext context, DescriptionItem item) {
    final theme = Theme.of(context);
    return Text(
      item.value,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
