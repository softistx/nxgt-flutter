import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// What a screen or a list shows when there is nothing to show yet.
///
/// An icon, a heading, a sentence and an optional [action] (a button that
/// creates the first item, say), centred. The heading is a semantics header and
/// the whole block is a live region, so a list that turns empty is announced.
/// Both texts default to the localized "Nothing here yet" copy.
class EmptyState extends StatelessWidget {
  /// Creates an EmptyState.
  const new({this.title, this.message, this.icon, this.action, super.key});

  /// The heading; defaults to the localized "Nothing here yet".
  final String? title;

  /// The sentence under the heading; defaults to the localized "There is
  /// nothing to show for now.".
  final String? message;

  /// The illustration above the heading, decorative. Defaults to an inbox.
  final Widget? icon;

  /// A call to action under the message, usually a button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.materialL10n;
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        // The role and the live region sit on two nodes: Flutter refuses
        // both on one.
        child: Semantics(
          container: true,
          role: SemanticsRole.status,
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                ExcludeSemantics(
                  child: IconTheme(
                    data: IconThemeData(size: 48, color: colors.outline),
                    child: icon ?? const Icon(Icons.inbox_outlined),
                  ),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    title ?? l10n.feedbackEmptyTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  message ?? l10n.feedbackEmptyMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (action != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: action,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
