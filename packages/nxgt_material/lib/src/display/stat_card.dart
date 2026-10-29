import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';
import 'package:nxgt_material/src/theme/tone_colors.dart';
import 'package:nxgt_material/src/theme/tones.dart';

/// The direction a [StatCard]'s figure moved.
///
/// Each direction is drawn with its own icon and spoken as a word, so the
/// trend never rests on colour alone.
enum StatTrend {
  /// The figure rose.
  up,

  /// The figure fell.
  down,

  /// The figure did not move.
  flat,
}

IconData _trendIcon(StatTrend trend) => switch (trend) {
  StatTrend.up => Icons.trending_up,
  StatTrend.down => Icons.trending_down,
  StatTrend.flat => Icons.trending_flat,
};

String _trendLabel(NxgtMaterialLocalizations l10n, StatTrend trend) =>
    switch (trend) {
      StatTrend.up => l10n.displayTrendUp,
      StatTrend.down => l10n.displayTrendDown,
      StatTrend.flat => l10n.displayTrendFlat,
    };

/// Success when it rises, error when it falls, neutral when flat; swapped
/// when a rise is bad ([positiveIsUp] `false`).
ToneColors _trendColors(
  Tones tones,
  StatTrend trend, {
  required bool positiveIsUp,
}) => switch (trend) {
  StatTrend.flat => tones.neutral,
  StatTrend.up => positiveIsUp ? tones.success : tones.error,
  StatTrend.down => positiveIsUp ? tones.error : tones.success,
};

/// A key figure in a card: a [label], its [value] and how it moved.
///
/// Built on a Material 3 `Card`. The [delta] (such as "4 %") sits in a pill
/// tinted by [trend] with AA colours, and the trend is drawn as an icon and
/// spoken as a word ("Revenue, 1 200, up 4 %"), never conveyed by colour
/// alone. Without [onTap] the card is not focusable; with it the whole card is
/// a button of at least 48 dp. It is not a `ListTile` (a row in a list).
class StatCard extends StatelessWidget {
  /// Creates a StatCard.
  const new({
    required this.label,
    required this.value,
    this.delta,
    this.trend,
    this.positiveIsUp = true,
    this.icon,
    this.onTap,
    super.key,
  });

  /// What the figure measures, such as "Revenue".
  final String label;

  /// The figure, already formatted, such as "1 200".
  final String value;

  /// The change, already formatted, such as "4 %". Shown in a pill with the
  /// trend's icon; without it only the [trend] icon is shown.
  final String? delta;

  /// How the figure moved; sets the pill's icon, spoken word and tone.
  /// Without it a [delta] is shown in the neutral tone, with no word.
  final StatTrend? trend;

  /// Whether a rise is good (`true`, the default) or bad, as for a cost: it
  /// swaps the success and error tones of [StatTrend.up] and
  /// [StatTrend.down]. The icon and the spoken word do not change.
  final bool positiveIsUp;

  /// An icon drawn at the end of the label row, hidden from screen readers.
  final IconData? icon;

  /// Called when the card is tapped. Makes the card a button.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: _body(context),
      ),
    );
    final tap = onTap;
    return Semantics(
      container: true,
      button: tap != null,
      focusable: tap != null,
      label: _spokenLabel(context),
      onTap: tap,
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: tap == null ? content : InkWell(onTap: tap, child: content),
      ),
    );
  }

  String _spokenLabel(BuildContext context) {
    final direction = trend;
    final change = [
      if (direction != null) _trendLabel(context.materialL10n, direction),
      ?delta,
    ].join(' ');
    return [label, value, if (change.isNotEmpty) change].join(', ');
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    final change = _change(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (icon != null)
              Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        ?change,
      ],
    );
  }

  Widget? _change(BuildContext context) {
    final text = delta;
    final direction = trend;
    if (text == null && direction == null) return null;
    final colors = direction == null
        ? context.tones.neutral
        : _trendColors(context.tones, direction, positiveIsUp: positiveIsUp);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.container,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (direction != null)
              Icon(_trendIcon(direction), size: 16, color: colors.onContainer),
            if (text != null)
              Flexible(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: colors.onContainer),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
