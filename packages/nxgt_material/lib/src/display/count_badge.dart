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

  /// Names [child] for screen readers, spoken before the count.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final label = semanticLabel;
    final spokenCount = count > 0
        ? context.materialL10n.displayCount(count)
        : null;
    return Semantics(
      container: true,
      label: [?label, ?spokenCount].join(', '),
      excludeSemantics: true,
      child: Badge.count(
        count: count,
        maxCount: max,
        isLabelVisible: count > 0,
        child: child,
      ),
    );
  }
}
