import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The invisible `TextFormField` of an `OtpField`.
///
/// Internal: 48 dp high over the slots (a 1 px font between two paddings),
/// with the helper or error text under it. [onError] is told when an error
/// appears and when it goes.
class OtpInput extends StatelessWidget {
  /// Creates the input.
  const new({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.validator,
    required this.onError,
    required this.enabled,
    required this.autofocus,
    this.onChanged,
    this.onSaved,
    this.autovalidateMode,
    this.helperText,
    super.key,
  });

  /// The digits.
  final TextEditingController controller;

  /// The focus node.
  final FocusNode focusNode;

  /// The most digits accepted.
  final int length;

  /// The composed validator.
  final FormFieldValidator<String> validator;

  /// Called with `true` when an error shows, `false` when it goes.
  final ValueChanged<bool> onError;

  /// Whether input is accepted.
  final bool enabled;

  /// Whether to focus on first show.
  final bool autofocus;

  /// Called at every edit.
  final ValueChanged<String>? onChanged;

  /// Called by `FormState.save`.
  final FormFieldSetter<String>? onSaved;

  /// When to validate; `null` follows the enclosing form.
  final AutovalidateMode? autovalidateMode;

  /// Text under the slots while there is no error.
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TextSelectionTheme(
      data: const TextSelectionThemeData(
        selectionColor: Colors.transparent,
        cursorColor: Colors.transparent,
        selectionHandleColor: Colors.transparent,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: enabled,
        validator: validator,
        autovalidateMode: autovalidateMode,
        onChanged: onChanged,
        onSaved: onSaved,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.oneTimeCode],
        autocorrect: false,
        enableSuggestions: false,
        textDirection: TextDirection.ltr,
        showCursor: false,
        style: const TextStyle(
          color: Colors.transparent,
          fontSize: 1,
          height: 1,
        ),
        inputFormatters: [_OtpFormatter(length)],
        errorBuilder: (context, error) => _ErrorProbe(
          onError: onError,
          child: Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ),
        decoration: InputDecoration(
          helperText: helperText,
          helperStyle: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          isDense: false,
          // Pinned so an app theme cannot resize the 48 dp input.
          constraints: const BoxConstraints(),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 23.5),
        ),
      ),
    );
  }
}

/// Keeps digits only, at most `length` of them.
///
/// A pasted or autofilled chunk holding `length` digits or more replaces the
/// whole code, so pasting a full code works over typed digits and into a full
/// field; anything else is stripped to digits and cut at `length`.
class _OtpFormatter extends TextInputFormatter {
  const new(this.length);

  final int length;

  static final _nonDigit = RegExp(r'\D');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    var digits = text.replaceAll(_nonDigit, '');
    // The inserted chunk is what the old selection (the end when it is
    // unknown) became: the new text minus the old text around it.
    final old = oldValue.text;
    final sel = oldValue.selection.isValid
        ? oldValue.selection
        : TextSelection.collapsed(offset: old.length);
    final head = old.substring(0, sel.start);
    final tail = old.substring(sel.end);
    if (text.length >= head.length + tail.length &&
        text.startsWith(head) &&
        text.endsWith(tail)) {
      final chunk = text
          .substring(head.length, text.length - tail.length)
          .replaceAll(_nonDigit, '');
      if (chunk.length >= length) digits = chunk;
    }
    if (digits.length > length) digits = digits.substring(0, length);
    if (digits == text) return newValue;
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

/// Reports that an error is shown while it is in the tree.
class _ErrorProbe extends StatefulWidget {
  const new({required this.onError, required this.child});

  final ValueChanged<bool> onError;
  final Widget child;

  @override
  State<_ErrorProbe> createState() => _ErrorProbeState();
}

class _ErrorProbeState extends State<_ErrorProbe> {
  late final ValueChanged<bool> _onError = widget.onError;

  void _report(bool value) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _onError(value));

  @override
  void initState() {
    super.initState();
    _report(true);
  }

  @override
  void dispose() {
    _report(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
