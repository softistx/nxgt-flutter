import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// The Material 3 button style an [AsyncButton] is drawn in.
enum AsyncButtonVariant {
  /// A [FilledButton], the highest emphasis.
  filled,

  /// A tonal [FilledButton], medium emphasis.
  tonal,

  /// An [OutlinedButton], medium-low emphasis.
  outlined,

  /// A [TextButton], the lowest emphasis.
  text,
}

/// A button whose action is asynchronous: it shows a spinner and ignores
/// further presses until the returned [Future] completes.
///
/// Prefer it to a bare [FilledButton] whenever the press starts a request, so
/// the user cannot submit twice. It stays focusable while busy (it is not
/// disabled), so keyboard focus is not lost, and a screen reader hears
/// "Loading" as its value. An error thrown by [onPressed] is reported with
/// [FlutterError.reportError] and the button becomes idle again.
class AsyncButton extends StatefulWidget {
  /// Creates an AsyncButton.
  const new({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AsyncButtonVariant.filled,
    this.loading,
    super.key,
  });

  /// The text shown, also read by screen readers.
  final String label;

  /// The action; the button is busy until the future completes. `null`
  /// disables the button.
  final Future<void> Function()? onPressed;

  /// An icon shown before the label, replaced by the spinner while busy.
  final Widget? icon;

  /// The Material 3 style of the button.
  final AsyncButtonVariant variant;

  /// Forces the busy state when not null, for a state held by the caller (a
  /// bloc, a provider). `null` lets the button track [onPressed] itself.
  final bool? loading;

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _pending = false;

  bool get _busy => widget.loading ?? _pending;

  Future<void> _press() async {
    if (_busy) return;
    setState(() => _pending = true);
    try {
      await widget.onPressed!();
    } on Object catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'nxgt_material',
          context: ErrorDescription('while running an AsyncButton action'),
        ),
      );
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _busy;
    final onPressed = widget.onPressed == null ? null : (busy ? () {} : _press);
    final label = Text(widget.label);
    final icon = busy ? const _Spinner() : widget.icon;
    final button = switch (widget.variant) {
      AsyncButtonVariant.filled =>
        icon == null
            ? FilledButton(onPressed: onPressed, child: label)
            : FilledButton.icon(onPressed: onPressed, icon: icon, label: label),
      AsyncButtonVariant.tonal =>
        icon == null
            ? FilledButton.tonal(onPressed: onPressed, child: label)
            : FilledButton.tonalIcon(
                onPressed: onPressed,
                icon: icon,
                label: label,
              ),
      AsyncButtonVariant.outlined =>
        icon == null
            ? OutlinedButton(onPressed: onPressed, child: label)
            : OutlinedButton.icon(
                onPressed: onPressed,
                icon: icon,
                label: label,
              ),
      AsyncButtonVariant.text =>
        icon == null
            ? TextButton(onPressed: onPressed, child: label)
            : TextButton.icon(onPressed: onPressed, icon: icon, label: label),
    };
    return MergeSemantics(
      child: Semantics(
        value: busy ? context.materialL10n.feedbackLoading : null,
        child: button,
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 18,
      child: ExcludeSemantics(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
