import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nxgt_material/src/fields/field_input.dart';
import 'package:nxgt_material/src/fields/validators.dart';

/// A text field for a phone number.
///
/// Opens the phone keypad, accepts only the characters of a number (digits,
/// a `+` only at the start, spaces, dots, dashes and parentheses), offers the
/// saved
/// number to autofill and rejects one that cannot be dialled. It does not
/// reformat the text; parse it with your own phone library when you need an
/// E.164 value.
class PhoneField extends StatelessWidget {
  /// Creates a PhoneField.
  const new({
    required this.label,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.helperText,
    this.hintText,
    this.required = false,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

  /// The label, floating above the value once the field has one, and read by
  /// screen readers.
  final String label;

  /// Controls the text; mutually exclusive with [initialValue].
  final TextEditingController? controller;

  /// The text the field starts with.
  final String? initialValue;

  /// The focus node of the input.
  final FocusNode? focusNode;

  /// Called with the new text at every edit.
  final ValueChanged<String>? onChanged;

  /// Called by `FormState.save` with the text.
  final FormFieldSetter<String>? onSaved;

  /// Called when the user submits from the keyboard.
  final ValueChanged<String>? onFieldSubmitted;

  /// An extra validator, run after the built-in ones.
  final FormFieldValidator<String>? validator;

  /// When to validate; `null` follows the enclosing [Form].
  final AutovalidateMode? autovalidateMode;

  /// Whether the field accepts input.
  final bool enabled;

  /// A hint shown under the field while there is no error.
  final String? helperText;

  /// A placeholder shown while the field is empty and focused.
  final String? hintText;

  /// Whether an empty value is an error.
  final bool required;

  /// The keyboard action button.
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final v = Validators.of(context);
    return FieldInput(
      label: label,
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      onChanged: onChanged,
      onSaved: onSaved,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      helperText: helperText,
      hintText: hintText,
      validator: v.compose([if (required) v.required(), v.phone(), validator]),
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
