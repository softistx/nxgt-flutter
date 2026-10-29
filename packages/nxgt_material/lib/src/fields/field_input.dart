import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The `TextFormField` every text field of this package is built on.
///
/// Internal: it only fixes the shared decoration (a floating label, no
/// counter unless asked) so each field states just what is its own.
class FieldInput extends StatelessWidget {
  /// Creates the input.
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
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.sensitive = false,
    this.autocorrect = true,
    this.suffixIcon,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    super.key,
  });

  /// The floating label.
  final String label;

  /// Controls the text.
  final TextEditingController? controller;

  /// The starting text.
  final String? initialValue;

  /// The focus node.
  final FocusNode? focusNode;

  /// Called at every edit.
  final ValueChanged<String>? onChanged;

  /// Called by `FormState.save`.
  final FormFieldSetter<String>? onSaved;

  /// Called on keyboard submit.
  final ValueChanged<String>? onFieldSubmitted;

  /// The validator.
  final FormFieldValidator<String>? validator;

  /// When to validate.
  final AutovalidateMode? autovalidateMode;

  /// Whether input is accepted.
  final bool enabled;

  /// Text under the field.
  final String? helperText;

  /// Placeholder.
  final String? hintText;

  /// The keyboard.
  final TextInputType? keyboardType;

  /// The keyboard action button.
  final TextInputAction? textInputAction;

  /// The autofill hints.
  final Iterable<String>? autofillHints;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Capitalization.
  final TextCapitalization textCapitalization;

  /// Whether the text is hidden.
  final bool obscureText;

  /// Whether the keyboard may correct the text; `sensitive` turns it off.
  final bool autocorrect;

  /// A secret: never autocorrected or suggested, always one line.
  final bool sensitive;

  /// A widget at the end of the field.
  final Widget? suffixIcon;

  /// Lines at rest.
  final int? minLines;

  /// Lines it grows to.
  final int? maxLines;

  /// Character limit and counter.
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      onChanged: onChanged,
      onSaved: onSaved,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      autocorrect: autocorrect && !sensitive,
      enableSuggestions: !sensitive,
      minLines: minLines,
      maxLines: sensitive ? 1 : maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        alignLabelWithHint: (maxLines ?? 2) > 1,
      ),
    );
  }
}
