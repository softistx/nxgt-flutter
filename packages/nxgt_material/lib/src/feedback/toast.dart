import 'package:flutter/material.dart';
import 'package:nxgt_material/src/feedback/feedback_tone.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';

/// `context.showToast`, a short message over the screen.
extension ToastContext on BuildContext {
  /// Shows [message] in a floating `SnackBar` of the nearest
  /// `ScaffoldMessenger`, replacing the one on screen, and returns its
  /// controller.
  ///
  /// Without a [tone] it is the theme's plain snackbar. With one it is tinted
  /// with the theme's `Tones`,
  /// drawn with the tone's icon, and read as "tone: message", since colour
  /// alone says nothing to a screen reader. A `SnackBar` is itself a live
  /// region, so the message is announced when it appears.
  ///
  /// Throws without a `ScaffoldMessenger` (any `MaterialApp` provides one).
  ///
  /// [actionLabel] with [onAction] adds a snackbar action ("Undo"). The toast
  /// closes by itself after [duration], and has a close button when
  /// [dismissible] is true. Use it for the outcome of something the user did;
  /// for a message that must stay, use an `InlineAlert`.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showToast(
    String message, {
    FeedbackTone? tone,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool dismissible = false,
  }) {
    assert(
      (actionLabel == null) == (onAction == null),
      'showToast: actionLabel and onAction go together.',
    );
    final messenger = ScaffoldMessenger.of(this)..hideCurrentSnackBar();
    final theme = Theme.of(this);
    final colors = tone?.colors(tones);
    final foreground =
        colors?.onContainer ?? theme.colorScheme.onInverseSurface;
    final text = Text(message);
    return messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: colors?.container,
        showCloseIcon: dismissible,
        closeIconColor: foreground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.md),
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: foreground,
                onPressed: onAction!,
              ),
        content: tone == null
            ? text
            : Semantics(
                label: '${tone.label(materialL10n)}: $message',
                excludeSemantics: true,
                child: Row(
                  spacing: 12,
                  children: [
                    Icon(tone.icon, color: foreground),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: foreground),
                        child: text,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
