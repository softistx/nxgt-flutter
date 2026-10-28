import 'package:flutter/material.dart';
import 'package:nxgt_material/src/actions/async_button.dart';

/// The button that submits the enclosing [Form].
///
/// Pressing it validates the form; when every field is valid it saves them
/// (`FormState.save`) and then awaits [onSubmit], showing the spinner of an
/// [AsyncButton] meanwhile so the form cannot be sent twice. When a field is
/// invalid nothing is sent: the fields show their errors, the SDK announces
/// the first error (`SemanticsService` / live region), and the button also
/// scrolls to the first invalid field, in tree order, and moves focus to it.
///
/// It must be inside a [Form] (a descendant of it): debug builds assert it
/// when the button is built, and a release build reports a [FlutterError] when
/// it is pressed (see the troubleshooting page).
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
    final invalid = form.validateGranularly();
    if (invalid.isNotEmpty) {
      _reveal(invalid.first);
      return;
    }
    form.save();
    await onSubmit!();
  }

  /// Scrolls to [field] and focuses its text input, when it has one.
  static void _reveal(FormFieldState<Object?> field) {
    final context = field.context;
    Scrollable.ensureVisible(context);
    FocusNode? node;
    void visit(Element element) {
      if (node != null) return;
      if (element is StatefulElement && element.state is EditableTextState) {
        node = (element.state as EditableTextState).widget.focusNode;
        return;
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    node?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      Form.maybeOf(context) != null,
      'SubmitButton was used outside a Form.',
    );
    return AsyncButton(
      label: label,
      icon: icon,
      variant: variant,
      onPressed: onSubmit == null ? null : () => _submit(context),
    );
  }
}
