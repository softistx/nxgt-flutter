import 'package:flutter/material.dart';
import 'package:nxgt_material/src/fields/field_input.dart';
import 'package:nxgt_material/src/fields/validators.dart';

/// A multi-line text field that grows with its content, for comments and
/// descriptions.
///
/// Starts at [minLines] lines and grows up to [maxLines], then scrolls. The
/// keyboard action is a new line, so submit with a button
/// (`SubmitButton`). With [maxLength] it shows a counter and stops typing at
/// the limit.
class TextAreaField extends StatelessWidget {
  /// Creates a TextAreaField.
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
    this.minLines = 3,
    this.maxLines = 8,
    this.maxLength,
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

  /// The height at rest, in lines.
  final int minLines;

  /// The height the field grows to, in lines.
  final int maxLines;

  /// The most characters accepted; shows a counter when set.
  final int? maxLength;

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
      validator: v.compose([if (required) v.required(), validator]),
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
    );
  }
}
