import 'package:flutter/material.dart';
import 'package:nxgt_material/src/fields/text_field_base.dart';
import 'package:nxgt_material/src/fields/validators.dart';

/// A text field for an email address.
///
/// Opens the email keyboard, offers the saved addresses to autofill, moves
/// to the next field on submit and rejects a malformed address with a
/// localized message. Prefer it to a bare [TextFormField] whenever the value
/// is an email, so these settings are not forgotten.
class EmailField extends TextFieldBase {
  /// Creates an EmailField.
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
      composed: v.compose([if (required) v.required(), v.email(), validator]),
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
    );
  }
}
