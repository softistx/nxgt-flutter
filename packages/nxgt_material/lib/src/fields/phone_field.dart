import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nxgt_material/src/fields/text_field_base.dart';
import 'package:nxgt_material/src/fields/validators.dart';

/// A text field for a phone number.
///
/// Opens the phone keypad, accepts only the characters of a number (digits,
/// a `+` only at the start, spaces, dots, dashes and parentheses), offers the
/// saved
/// number to autofill and rejects one that cannot be dialled. It does not
/// reformat the text; parse it with your own phone library when you need an
/// E.164 value.
class PhoneField extends TextFieldBase {
  /// Creates a PhoneField.
  const new({
    required super.label,
    super.controller,
    super.initialValue,
    super.focusNode,
    super.onChanged,
    super.onSaved,
    super.onFieldSubmitted,
    super.validator,
    super.autovalidateMode,
    super.enabled = true,
    super.helperText,
    super.hintText,
    this.required = false,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

  /// Whether an empty value is an error.
  final bool required;

  /// The keyboard action button.
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final v = Validators.of(context);
    return buildInput(
      composed: v.compose([if (required) v.required(), v.phone(), validator]),
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: const [_PhoneFilter()],
    );
  }
}

/// Keeps the characters of a number, and a `+` only as the first one.
class _PhoneFilter extends TextInputFormatter {
  const new();

  static final _dropped = RegExp(r'[^\d+\s().\-]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final kept = newValue.text.replaceAll(_dropped, '');
    final text = kept.isEmpty
        ? kept
        : kept[0] + kept.substring(1).replaceAll('+', '');
    if (text == newValue.text) return newValue;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
