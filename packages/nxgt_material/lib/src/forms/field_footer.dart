import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nxgt_material/src/feedback/live_region.dart';

/// The helper text, replaced by the announced error when there is one.
///
/// The helper text is left out of the semantics: the control it sits under
/// already reads it as its hint. The 16 dp start inset matches the padding of
/// a `ListTile`, so the text lines up with the tile's content edge. Internal,
/// not exported.
class ChoiceFooter extends StatelessWidget {
  /// Creates the footer.
  const new({required this.helperText, required this.errorText, super.key});

  /// The helper text, if any.
  final String? helperText;

  /// The error to announce, if any.
  final String? errorText;

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
      // The control already carries the helper text as its hint.
      child: ExcludeSemantics(
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
