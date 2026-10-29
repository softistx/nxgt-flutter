import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nxgt_material/src/feedback/live_region.dart';

/// The body of a group: a visible title and a container node named by it,
/// holding the options in [child].
class ChoiceGroupBody extends StatelessWidget {
  /// Creates the body.
  const new({
    required this.label,
    required this.hint,
    required this.hasError,
    required this.child,
    super.key,
  });

  /// The visible title.
  final String label;

  /// The hint of the container node.
  final String? hint;

  /// Whether the title takes the error colour.
  final bool hasError;

  /// The options.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      hint: hint,
      // Its own Material, so a coloured ancestor neither hides the ink
      // splashes nor trips the ListTile assertion.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // The visible title; the container node carries it.
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: hasError ? theme.colorScheme.error : null,
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// The helper text, replaced by the announced error when there is one.
///
/// The 16 dp start inset matches the padding of a `ListTile`, so the text
/// lines up with the tile's content edge.
class ChoiceFooter extends StatelessWidget {
  /// Creates the footer.
  const new({
    required this.helperText,
    required this.errorText,
    required this.excludeHelper,
    super.key,
  });

  /// The helper text, if any.
  final String? helperText;

  /// The error to announce, if any.
  final String? errorText;

  /// Whether the helper text is left out of the semantics.
  final bool excludeHelper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = errorText;
    final helper = helperText;
    if (error != null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
        // The role and the live region sit on two nodes: Flutter refuses
        // both on one.
        child: Semantics(
          container: true,
          role: SemanticsRole.alert,
          child: Semantics(
            container: true,
            liveRegion: liveRegionUnderRole,
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      );
    }
    if (helper == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: ExcludeSemantics(
        excluding: excludeHelper,
        child: Text(
          helper,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
