import 'package:flutter/material.dart';

/// The body of a group: a visible title and a container node named by it,
/// holding the options in [child]. Internal, not exported.
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
