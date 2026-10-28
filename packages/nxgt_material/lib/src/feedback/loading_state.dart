import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// What a screen or a list shows while its data loads.
///
/// A progress indicator and a caption, centred. The caption is a live region,
/// so "Loading" is spoken when the state appears. With reduced motion
/// (`MediaQuery.disableAnimations`) the spinner is replaced by a static icon:
/// the caption stays, so the state is still readable.
class LoadingState extends StatelessWidget {
  /// Creates a LoadingState.
  const new({this.message, super.key});

  /// The caption; defaults to the localized "Loading".
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              ExcludeSemantics(
                child: reduced
                    ? Icon(
                        Icons.hourglass_top,
                        size: 40,
                        color: theme.colorScheme.primary,
                      )
                    : const SizedBox.square(
                        dimension: 40,
                        child: CircularProgressIndicator(),
                      ),
              ),
              Text(
                message ?? context.materialL10n.feedbackLoading,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
