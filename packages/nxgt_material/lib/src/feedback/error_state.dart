import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nxgt_material/src/actions/async_button.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// What a screen or a list shows when its data failed to load.
///
/// An icon, a heading, a sentence and, when [onRetry] is given, a "Retry"
/// [AsyncButton] that spins until the retry completes. The heading is a
/// semantics header and the block a live region, so the failure is announced.
/// Both texts default to the localized "Something went wrong" copy; never put a
/// raw exception in [message].
class ErrorState extends StatelessWidget {
  /// Creates an ErrorState.
  const new({
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  /// The heading; defaults to the localized "Something went wrong".
  final String? title;

  /// The sentence under the heading; defaults to the localized "An error
  /// occurred. Try again in a moment.".
  final String? message;

  /// Runs the retry; the button is busy until the future completes. `null`
  /// hides the button.
  final Future<void> Function()? onRetry;

  /// The text of the retry button; defaults to the localized "Retry".
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.materialL10n;
    final colors = theme.colorScheme;
    final onRetry = this.onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        // The role and the live region sit on two nodes: Flutter refuses
        // both on one.
        child: Semantics(
          container: true,
          role: SemanticsRole.alert,
          child: Semantics(
            container: true,
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colors.error,
                  ),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    title ?? l10n.feedbackErrorTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  message ?? l10n.feedbackErrorMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (onRetry != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: AsyncButton(
                      label: retryLabel ?? l10n.actionsRetry,
                      icon: const Icon(Icons.refresh),
                      variant: AsyncButtonVariant.tonal,
                      onPressed: onRetry,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
