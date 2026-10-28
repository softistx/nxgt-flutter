import 'package:flutter/material.dart';
import 'package:nxgt_material/src/feedback/feedback_tone.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';

/// A message that stays in the page, next to what it is about: a form error
/// summary, a warning above a table, a confirmation under a button.
///
/// Four tones ([FeedbackTone]) with an icon and AA-solved colours from
/// `context.tones`, so it needs a theme built from a `ThemeSpec`. It is a
/// live region with the semantics role `alert` for a warning or an error and
/// `status` otherwise, and a screen reader says the tone before the text. It
/// is not a `SnackBar` (that is `context.showToast`) nor a `MaterialBanner`
/// (a screen-level strip with actions).
class InlineAlert extends StatelessWidget {
  /// Creates an InlineAlert.
  const new({
    required this.message,
    this.title,
    this.tone = FeedbackTone.info,
    this.icon,
    this.action,
    this.onDismiss,
    super.key,
  });

  /// The text of the alert.
  final String message;

  /// A bold first line.
  final String? title;

  /// The meaning, which sets the colours, the icon and the announcement.
  final FeedbackTone tone;

  /// Replaces the tone's icon.
  final IconData? icon;

  /// An action under the text, usually a `TextButton`.
  final Widget? action;

  /// Shows a close button that calls it. The alert does not hide itself.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.materialL10n;
    final colors = tone.colors(context.tones);
    final title = this.title;
    final onDismiss = this.onDismiss;
    // The role and the live region sit on two nodes: Flutter refuses both on
    // one. The role names what the box is, the live region announces its text.
    return Semantics(
      container: true,
      role: tone.role,
      child: Material(
        color: colors.container,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radii.md),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, onDismiss == null ? 16 : 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              ExcludeSemantics(
                child: Icon(
                  icon ?? tone.icon,
                  color: colors.onContainer,
                  size: 24,
                ),
              ),
              Expanded(
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Semantics(
                        label: tone.label(l10n),
                        child: const SizedBox.shrink(),
                      ),
                      if (title != null)
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.onContainer,
                          ),
                        ),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onContainer,
                        ),
                      ),
                      if (action != null)
                        Theme(
                          data: theme.copyWith(
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: colors.onContainer,
                              ),
                            ),
                          ),
                          child: action!,
                        ),
                    ],
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  tooltip: l10n.actionsClose,
                  color: colors.onContainer,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
