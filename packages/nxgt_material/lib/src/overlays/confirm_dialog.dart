import 'package:flutter/material.dart';
import 'package:nxgt_material/src/actions/async_button.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/theme/targets.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';
import 'package:nxgt_material/src/theme/tone_colors.dart';
import 'package:nxgt_material/src/theme/tone_style.dart';

/// A dialog that asks the user to confirm an action, such as a deletion.
///
/// Prefer `context.confirm` to show it and read the answer. It is a
/// dialog at every window size, built on `AlertDialog`, so a screen reader
/// hears its title as the name of the route.
///
/// The confirm action runs [onConfirm] through an [AsyncButton]: it shows a
/// spinner and ignores further presses until the future completes, then the
/// dialog pops `true`. While it runs there is no way out of the dialog, so
/// give the future a timeout. If
/// [onConfirm] throws, the error is reported with [FlutterError.reportError],

///
/// Focus starts on Cancel when [destructive], else on Confirm. Escape, a tap
/// on the barrier and the system back gesture pop `false`.
class ConfirmDialog extends StatefulWidget {
  /// Creates a confirm dialog.
  const new({
    required this.title,
    required this.message,
    this.confirmLabel,
    this.destructive = false,
    this.onConfirm,
    super.key,
  }) : assert(title != '', 'ConfirmDialog.title must not be empty.');

  /// The question, also the name of the dialog for screen readers.
  final String title;

  /// What will happen if the user confirms. It scrolls when it is long.
  final String message;

  /// The label of the confirm action; the localized "Confirm" when `null`.
  final String? confirmLabel;

  /// Whether the action destroys something: the confirm action is drawn with
  /// the error tone and the focus starts on Cancel.
  final bool destructive;

  /// The work the confirm action does. The dialog pops `true` once it
  /// completes. `null` pops `true` at once.
  final Future<void> Function()? onConfirm;

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _busy = false;

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onConfirm?.call();
    } on Object {
      // The AsyncButton reports it; the dialog stays open and usable.
      if (mounted) setState(() => _busy = false);
      rethrow;
    }
    // On success the dialog stays locked while it animates out, so a tap or
    // Escape cannot pop the page beneath.
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.materialL10n;
    final error = context.tones.error;
    final theme = Theme.of(context);
    final confirmTheme = _confirmButtonTheme(
      theme.filledButtonTheme,
      widget.destructive ? error : null,
    );
    return Actions(
      // Escape pops the topmost present route; once this one is popping that
      // is the page beneath, so the key does nothing while locked.
      actions: _busy
          ? {DismissIntent: DoNothingAction()}
          : const <Type, Action<Intent>>{},
      child: PopScope(
        canPop: !_busy,
        child: AlertDialog(
          title: Text(widget.title),
          content: Text(widget.message),
          scrollable: true,
          semanticLabel: widget.title,
          actions: [
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              autofocus: widget.destructive,
              style: targetStyle,
              child: Text(l10n.actionsCancel),
            ),
            Theme(
              data: theme.copyWith(filledButtonTheme: confirmTheme),
              child: AsyncButton(
                label: widget.confirmLabel ?? l10n.actionsConfirm,
                onPressed: _confirm,
                loading: _busy,
                autofocus: !widget.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

FilledButtonThemeData _confirmButtonTheme(
  FilledButtonThemeData base,
  ToneColors? error,
) {
  final style = targetStyle.copyWith(
    backgroundColor: error == null ? null : whenEnabled(error.color),
    foregroundColor: error == null ? null : whenEnabled(error.onColor),
  );
  return FilledButtonThemeData(style: base.style?.merge(style) ?? style);
}

/// `context.confirm`, asks the user to confirm an action in a dialog.
extension ConfirmContext on BuildContext {
  /// Shows a [ConfirmDialog] and returns `true` when the user confirmed (and
  /// [onConfirm], if any, succeeded), `false` when they cancelled or
  /// dismissed it with Escape, the barrier or the back gesture.
  ///
  /// ```dart
  /// final ok = await context.confirm(
  ///   title: 'Delete invoice?',
  ///   message: 'This cannot be undone.',
  ///   confirmLabel: 'Delete',
  ///   destructive: true,
  ///   onConfirm: () => repository.delete(id),
  /// );
  /// ```
  ///
  /// Throws without a `Navigator` above (any `MaterialApp` provides one).
  Future<bool> confirm({
    required String title,
    required String message,
    String? confirmLabel,
    bool destructive = false,
    Future<void> Function()? onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: this,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        destructive: destructive,
        onConfirm: onConfirm,
      ),
    );
    return confirmed ?? false;
  }
}
