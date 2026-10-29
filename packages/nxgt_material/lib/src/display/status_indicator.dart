import 'package:flutter/material.dart';
import 'package:nxgt_material/src/feedback/feedback_tone.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';

/// A short status in the page: a dot and a label, such as "Paid" or "Late".
///
/// The [tone] ([FeedbackTone]) sets AA-solved colours from `context.tones`,
/// and a screen reader says the tone's localized name before the label, so the
/// meaning never rests on colour alone. With `dot: false` the tone's icon is
/// drawn instead of the dot, for a status that must differ by shape too. It
/// is not a `Chip` (which can be tapped) nor an `InlineAlert` (a message).
class StatusIndicator extends StatelessWidget {
  /// Creates a StatusIndicator.
  const new({
    required this.label,
    this.tone = FeedbackTone.info,
    this.dot = true,
    super.key,
  });

  /// The text shown, also read by screen readers after the tone.
  final String label;

  /// The meaning, which sets the colours and the spoken tone.
  final FeedbackTone tone;

  /// Draws a round dot before the label; `false` draws the tone's icon.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors(context.tones);
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: '${tone.label(context.materialL10n)}, $label',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: colors.container,
          shape: const StadiumBorder(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              if (dot)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.onContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 8),
                )
              else
                Icon(tone.icon, size: 16, color: colors.onContainer),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
