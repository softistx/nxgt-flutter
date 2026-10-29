import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// A count on the corner of [child], such as unread messages on an icon.
///
/// Built on Material 3 `Badge.count`: it shows `99+` above [max] and hides at
/// 0. A screen reader says [semanticLabel] (what [child] is) and then the
/// localized count ("3 items"), always the real count, never the capped text.
class CountBadge extends StatelessWidget {
  /// Creates a CountBadge.
  const new({
    required this.count,
    required this.child,
    this.max = 99,
    this.semanticLabel,
    super.key,
  }) : assert(count >= 0, 'CountBadge.count must not be negative.'),
       assert(max > 0, 'CountBadge.max must be positive.');

  /// The number shown. At 0 the badge is hidden and [child] stays.
  final int count;

  /// What the badge sits on, usually an `Icon`.
  final Widget child;

  /// The largest number written out; above it the badge reads `<max>+`.
  final int max;

  /// Names [child] for screen readers, spoken before the count. Without it
  /// the child keeps its own semantics.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Release builds degrade: a negative count hides the badge, a max below 1
    // counts as 1.
    final shown = count < 0 ? 0 : count;
    final badge = Badge.count(
      count: shown,
      maxCount: max < 1 ? 1 : max,
      isLabelVisible: shown > 0,
      child: child,
    );
    final label = semanticLabel;
    if (label == null) return badge;
    final spokenCount = shown > 0
        ? context.materialL10n.displayCount(shown)
        : null;
    return Semantics(
      container: true,
      label: [label, ?spokenCount].join(', '),
      excludeSemantics: true,
      child: badge,
    );
  }
}
