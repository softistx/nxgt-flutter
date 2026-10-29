import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nxgt_material/src/fields/field_input.dart';

/// The parameters every text field of this package shares.
///
/// Internal: a field extends it, forwards the shared parameters with
/// `super.` and builds its [FieldInput] with [buildInput], so none of them
/// is declared or passed on again.
abstract class TextFieldBase extends StatelessWidget {
  /// Creates the shared parameters.
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

  /// The [FieldInput] of this field: the shared parameters, and the rest as
  /// the field states it. [composed] is the field's validator once its
  /// built-in ones are added to [validator].
  @protected
  FieldInput buildInput({
    FormFieldValidator<String>? composed,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    bool sensitive = false,
    Widget? suffixIcon,
    int? minLines,
    int? maxLines = 1,
    int? maxLength,
  }) {
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
      validator: composed,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      sensitive: sensitive,
      suffixIcon: suffixIcon,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
    );
  }
}
