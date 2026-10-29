import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nxgt_material/src/actions/async_button.dart';
import 'package:nxgt_material/src/forms/submit_button.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/overlays/confirm_dialog.dart';
import 'package:nxgt_material/src/overlays/form_dialog_layouts.dart';

/// A form in a dialog: full-screen with a top app bar on a compact window,
/// a dialog with its actions at the bottom from the medium size up.
///
/// Prefer `context.showFormDialog` to show it. The widget is public to be
/// placed in a Widgetbook use case or a golden test, and needs a `Navigator`
/// and a `Material` ancestor.
///
/// It wraps [child] in a `Form` and offers a [SubmitButton] that validates it
/// and runs [onSubmit]. When the future completes, the dialog pops its value;
/// when it throws, the error is reported as [SubmitButton] does and the dialog
/// stays open. While [onSubmit] runs, and while the dialog animates out, it
/// cannot be closed.
///
/// Once a field changes (`Form.onChanged`), closing the dialog with the close
/// button, Cancel, Escape, a tap on the barrier or the back gesture first asks
/// "Discard changes?" through `context.confirm`. A dialog that was not changed
/// closes at once and pops `null`.
class FormDialog<T> extends StatefulWidget {
  /// Creates a form dialog.
  const new({
    required this.title,
    required this.child,
    required this.onSubmit,
    this.submitLabel,
    this.fullscreen = false,
    super.key,
  }) : assert(title != '', 'FormDialog.title must not be empty.');

  /// The title, also the name of the dialog for screen readers.
  final String title;

  /// The fields. It is placed in a `Form` and scrolls when it is taller than
  /// the room.
  final Widget child;

  /// Called with the form valid and saved. The value it completes with is the
  /// value the dialog pops. The dialog cannot be closed until it completes, so
  /// give the future a timeout.
  final Future<T> Function() onSubmit;

  /// The label of the submit action; the localized "Confirm" when `null`.
  final String? submitLabel;

  /// Whether to draw the full-screen layout (a `Scaffold` with an app bar)
  /// instead of the dialog. `context.showFormDialog` sets it from the window
  /// size when the dialog opens. Prefer `context.showFormDialog`, which picks
  /// the layout from the window size; this flag exists to place each layout
  /// directly (catalogue, goldens). The full-screen layout needs a bounded
  /// height.
  final bool fullscreen;

  @override
  State<FormDialog<T>> createState() => _FormDialogState<T>();
}

class _FormDialogState<T> extends State<FormDialog<T>> {
  bool _dirty = false;

  /// True from the press of Submit until the dialog is gone, so a tap or
  /// Escape cannot pop the page beneath while it animates out.
  bool _busy = false;

  bool _asking = false;

  /// Takes the focus when no field did, so Escape reaches the guard above.
  final _focus = FocusNode(debugLabel: 'FormDialog');

  @override
  void initState() {
    super.initState();
    if (!widget.fullscreen) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A field's `autofocus` is applied in a microtask after the frame.
      scheduleMicrotask(() {
        if (!mounted) return;
        // A field with `autofocus` has the focus; leave it there.
        if (FocusScope.of(context).focusedChild == null) _focus.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _changed() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    final T value;
    try {
      value = await widget.onSubmit();
    } on Object {
      // The AsyncButton reports it; the dialog stays open and usable.
      if (mounted) setState(() => _busy = false);
      rethrow;
    }
    if (mounted) Navigator.of(context).pop(value);
  }

  Future<void> _askToDiscard() async {
    if (_asking || _busy) return;
    _asking = true;
    final l10n = context.materialL10n;
    final bool discard;
    try {
      discard = await context.confirm(
        title: l10n.overlaysDiscardTitle,
        message: l10n.overlaysDiscardMessage,
        confirmLabel: l10n.overlaysDiscardConfirm,
        destructive: true,
      );
    } finally {
      _asking = false;
    }
    if (!discard || !mounted) return;
    setState(() => _busy = true);
    Navigator.of(context).pop();
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.materialL10n;
    final submit = withTargets(
      theme,
      SubmitButton(
        label: widget.submitLabel ?? l10n.actionsConfirm,
        onSubmit: _submit,
        variant: widget.fullscreen
            ? AsyncButtonVariant.text
            : AsyncButtonVariant.filled,
      ),
    );
    final body = widget.fullscreen
        ? formDialogFullscreen(
            context: context,
            theme: theme,
            title: widget.title,
            child: widget.child,
            submit: submit,
            busy: _busy,
            close: _close,
            focus: _focus,
          )
        : formDialogDialog(
            context: context,
            title: widget.title,
            child: widget.child,
            submit: submit,
            busy: _busy,
            close: _close,
          );
    return formDialogGuard(
      busy: _busy,
      fullscreen: false,
      close: _close,
      child: PopScope(
        canPop: !_busy && !_dirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_askToDiscard());
        },
        child: Form(onChanged: _changed, child: body),
      ),
    );
  }
}
