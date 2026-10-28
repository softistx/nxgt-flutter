import 'package:flutter/material.dart';
import 'package:nxgt_material/src/fields/field_input.dart';
import 'package:nxgt_material/src/fields/validators.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// A text field for a password, with a button that shows or hides it.
///
/// The text is obscured, never autocorrected or suggested, and offered to the
/// platform password manager (as a new password with [newPassword]). The
/// visibility button is a 48 dp toggle named "Show password" or "Hide
/// password" in the user's language.
class PasswordField extends StatefulWidget {
  /// Creates a PasswordField.
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
    this.minLength,
    this.newPassword = false,
    this.initiallyVisible = false,
    this.textInputAction = TextInputAction.done,
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

  /// The fewest characters accepted, for a sign-up or a change form.
  final int? minLength;

  /// Whether the user chooses a new password (sign-up, reset) rather than
  /// types an existing one; it changes the autofill hint so the password
  /// manager offers to generate one.
  final bool newPassword;

  /// Whether the text starts visible.
  final bool initiallyVisible;

  /// The keyboard action button.
  final TextInputAction textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late bool _visible = widget.initiallyVisible;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final v = Validators.of(context);
    final l10n = context.materialL10n;
    final min = w.minLength;
    return FieldInput(
      label: w.label,
      controller: w.controller,
      initialValue: w.initialValue,
      focusNode: w.focusNode,
      onChanged: w.onChanged,
      onSaved: w.onSaved,
      onFieldSubmitted: w.onFieldSubmitted,
      autovalidateMode: w.autovalidateMode,
      enabled: w.enabled,
      helperText: w.helperText,
      hintText: w.hintText,
      validator: v.compose([
        if (w.required) v.required(),
        if (min != null) v.minLength(min),
        w.validator,
      ]),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: w.textInputAction,
      autofillHints: [
        if (w.newPassword)
          AutofillHints.newPassword
        else
          AutofillHints.password,
      ],
      obscureText: !_visible,
      sensitive: true,
      suffixIcon: IconButton(
        tooltip: _visible ? l10n.fieldsHidePassword : l10n.fieldsShowPassword,
        isSelected: _visible,
        icon: const Icon(Icons.visibility_outlined),
        selectedIcon: const Icon(Icons.visibility_off_outlined),
        onPressed: w.enabled
            ? () => setState(() => _visible = !_visible)
            : null,
      ),
    );
  }
}
