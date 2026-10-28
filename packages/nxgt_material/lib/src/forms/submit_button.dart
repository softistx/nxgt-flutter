import 'package:flutter/material.dart';
import 'package:nxgt_material/src/actions/async_button.dart';

/// The button that submits the enclosing [Form].
///
/// Pressing it validates the form; when every field is valid it saves them
/// (`FormState.save`) and then awaits [onSubmit], showing the spinner of an
/// [AsyncButton] meanwhile so the form cannot be sent twice. When a field is
/// invalid nothing is sent: the fields show their errors, and the first one
/// is announced by screen readers.
///
/// It must be below a [Form]; otherwise pressing it reports a [FlutterError]
/// (see the troubleshooting page).
class SubmitButton extends StatelessWidget {
  /// Creates a SubmitButton.
  const new({
    required this.label,
    required this.onSubmit,
    this.icon,
    this.variant = AsyncButtonVariant.filled,
    super.key,
  });

  /// The text shown, also read by screen readers.
  final String label;

  /// Called with the form valid and saved; the button is busy until it
  /// completes. `null` disables the button.
  final Future<void> Function()? onSubmit;

  /// An icon shown before the label, replaced by the spinner while busy.
  final Widget? icon;

  /// The Material 3 style of the button.
  final AsyncButtonVariant variant;

  Future<void> _submit(BuildContext context) async {
    final form = Form.maybeOf(context);
    if (form == null) {
      throw FlutterError.fromParts([
        ErrorSummary('SubmitButton was used outside a Form.'),
        ErrorDescription(
          'It validates and saves the enclosing Form, so it has to be one of '
          "the Form's descendants.",
        ),
        ErrorHint('Wrap the fields and the button in a Form widget.'),
      ]);
    }
    if (!form.validate()) return;
    form.save();
    await onSubmit!();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncButton(
      label: label,
      icon: icon,
      variant: variant,
      onPressed: onSubmit == null ? null : () => _submit(context),
    );
  }
}
