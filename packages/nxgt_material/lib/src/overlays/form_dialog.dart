import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nxgt_material/src/actions/async_button.dart';
import 'package:nxgt_material/src/forms/submit_button.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/layout/window_size.dart';
import 'package:nxgt_material/src/overlays/confirm_dialog.dart';

const _minTarget = Size.square(48);

/// The widest the dialog grows, in logical pixels, from the medium size up.
const _dialogWidth = 560.0;

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
    final submit = _withTargets(
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
        ? _fullscreen(context, theme, submit)
        : _dialog(context, theme, submit);
    return _guard(
      fullscreen: false,
      child: PopScope(
        canPop: !_busy && !_dirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_askToDiscard());
        },
        child: Form(onChanged: _changed, child: body),
      ),
    );
  }

  /// Escape, locked while busy. A page route has no dismissible barrier to
  /// take the key, so on the full-screen layout the dialog takes it itself;
  /// the `Scaffold` has its own `Actions` for `DismissIntent`, so there it
  /// wraps the app bar and the body, not the `Scaffold`.
  Widget _guard({required bool fullscreen, required Widget child}) {
    final actions = <Type, Action<Intent>>{
      if (_busy)
        DismissIntent: DoNothingAction()
      else if (fullscreen)
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (_) {
            _close();
            return null;
          },
        ),
    };
    return Actions(actions: actions, child: child);
  }

  Widget _fullscreen(BuildContext context, ThemeData theme, Widget submit) {
    final l10n = context.materialL10n;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _guard(
          fullscreen: true,
          child: AppBar(
            automaticallyImplyLeading: false,
            leading: _withTargets(
              theme,
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.actionsClose,
                onPressed: _busy ? null : _close,
                style: _targetStyle,
              ),
            ),
            title: Semantics(
              header: true,
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: submit,
              ),
            ],
          ),
        ),
      ),
      body: _guard(
        fullscreen: true,
        child: Focus(
          focusNode: _focus,
          skipTraversal: true,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 24),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialog(BuildContext context, ThemeData theme, Widget submit) {
    return AlertDialog(
      title: Semantics(header: true, child: Text(widget.title)),
      content: SizedBox(width: _dialogWidth, child: widget.child),
      scrollable: true,
      semanticLabel: widget.title,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: _dialogWidth),
      actions: [
        TextButton(
          onPressed: _busy ? null : _close,
          style: _targetStyle,
          child: Text(context.materialL10n.actionsCancel),
        ),
        submit,
      ],
    );
  }
}

const _targetStyle = ButtonStyle(
  minimumSize: WidgetStatePropertyAll(_minTarget),
  tapTargetSize: MaterialTapTargetSize.padded,
  visualDensity: VisualDensity.standard,
);

/// [child] with the buttons below it kept at 48 dp on every platform.
Widget _withTargets(ThemeData theme, Widget child) {
  ButtonStyle merged(ButtonStyle? base) =>
      base?.merge(_targetStyle) ?? _targetStyle;
  return Theme(
    data: theme.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: merged(theme.filledButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: merged(theme.textButtonTheme.style),
      ),
    ),
    child: child,
  );
}

/// The full-screen route: no animation under reduced motion.
class _FormRoute<T> extends MaterialPageRoute<T> {
  new({required super.builder, required this.reduceMotion})
    : super(fullscreenDialog: true);

  final bool reduceMotion;

  @override
  Duration get transitionDuration =>
      reduceMotion ? Duration.zero : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? Duration.zero : super.reverseTransitionDuration;
}

/// `context.showFormDialog`, shows a form in a dialog that fits the window.
extension FormDialogContext on BuildContext {
  /// Shows the form built by [builder] under [title] and returns the value
  /// [onSubmit] completed with, or `null` when the user closed it.
  ///
  /// On a compact window (under 600 dp) the form is full-screen, with a top
  /// app bar holding the close button, the title and the submit action. From
  /// the medium size up it is a dialog up to 560 dp wide with Cancel and the
  /// submit action at the bottom. The size is read when the dialog opens.
  ///
  /// The builder's content is placed in a `Form`; the submit action validates
  /// it (an invalid form stays open, nothing is sent), saves it and runs
  /// [onSubmit], which returns the value to pop. If [onSubmit] throws, the
  /// error is reported with [FlutterError.reportError] and the dialog stays
  /// open. When a field has changed, closing the dialog asks to discard the
  /// changes first; the answer "Cancel" keeps it open. Focus returns to the
  /// control that opened it.
  ///
  /// ```dart
  /// final created = await context.showFormDialog<Invoice>(
  ///   title: 'New invoice',
  ///   submitLabel: 'Create',
  ///   builder: (context) => InvoiceFields(controller: controller),
  ///   onSubmit: () => repository.create(controller.draft),
  /// );
  /// ```
  ///
  /// Throws without a `Navigator` above (any `MaterialApp` provides one).
  Future<T?> showFormDialog<T>({
    required String title,
    required WidgetBuilder builder,
    required Future<T> Function() onSubmit,
    String? submitLabel,
  }) {
    final fullscreen = windowSize == WindowSize.compact;
    final reduceMotion = MediaQuery.disableAnimationsOf(this);
    final dialog = FormDialog<T>(
      title: title,
      onSubmit: onSubmit,
      submitLabel: submitLabel,
      fullscreen: fullscreen,
      child: Builder(builder: builder),
    );
    if (!fullscreen) {
      return showDialog<T>(
        context: this,
        animationStyle: reduceMotion ? AnimationStyle.noAnimation : null,
        builder: (_) => dialog,
      );
    }
    final navigator = Navigator.of(this, rootNavigator: true);
    final themes = InheritedTheme.capture(from: this, to: navigator.context);
    return navigator.push(
      _FormRoute<T>(
        reduceMotion: reduceMotion,
        builder: (_) => themes.wrap(dialog),
      ),
    );
  }
}
