import 'package:flutter/material.dart';
import 'package:nxgt_material/src/fields/text_field_base.dart';
import 'package:nxgt_material/src/fields/validators.dart';

/// A multi-line text field that grows with its content, for comments and
/// descriptions.
///
/// Starts at [minLines] lines and grows up to [maxLines], then scrolls. The
/// keyboard action is a new line, so submit with a button
/// (`SubmitButton`). With [maxLength] it shows a counter and stops typing at
/// the limit.
class TextAreaField extends TextFieldBase {
  /// Creates a TextAreaField.
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
    this.minLines = 3,
    this.maxLines = 8,
    this.maxLength,
    super.key,
  });

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
    return buildInput(
      composed: v.compose([if (required) v.required(), validator]),
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
    );
  }
}
