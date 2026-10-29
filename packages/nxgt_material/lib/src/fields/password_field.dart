import 'package:flutter/material.dart';
import 'package:nxgt_material/src/fields/text_field_base.dart';
import 'package:nxgt_material/src/fields/validators.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// A text field for a password, with a button that shows or hides it.
///
/// The text is obscured, never autocorrected or suggested, and offered to the
/// platform password manager (as a new password with [newPassword]). The
/// visibility button is a 48 dp toggle named "Show password" or "Hide
/// password" in the user's language.
class PasswordField extends TextFieldBase {
  /// Creates a PasswordField.
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
    this.minLength,
    this.newPassword = false,
    this.initiallyVisible = false,
    this.textInputAction = TextInputAction.done,
    super.key,
  });

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
  Widget build(BuildContext context) {
    final v = Validators.of(context);
    final l10n = context.materialL10n;
    final min = minLength;
    return _Visibility(
      initiallyVisible: initiallyVisible,
      builder: ({required visible, required toggle}) => buildInput(
        composed: v.compose([
          if (required) v.required(),
          if (min != null) v.minLength(min),
          validator,
        ]),
        keyboardType: TextInputType.visiblePassword,
        textInputAction: textInputAction,
        autofillHints: [
          if (newPassword)
            AutofillHints.newPassword
          else
            AutofillHints.password,
        ],
        obscureText: !visible,
        sensitive: true,
        suffixIcon: IconButton(
          tooltip: visible ? l10n.fieldsHidePassword : l10n.fieldsShowPassword,
          isSelected: visible,
          icon: const Icon(Icons.visibility_outlined),
          selectedIcon: const Icon(Icons.visibility_off_outlined),
          onPressed: enabled ? toggle : null,
        ),
      ),
    );
  }
}

/// Holds whether the password is shown, for the stateless [PasswordField].
class _Visibility extends StatefulWidget {
  const new({required this.initiallyVisible, required this.builder});

  final bool initiallyVisible;
  final Widget Function({required bool visible, required VoidCallback toggle})
  builder;

  @override
  State<_Visibility> createState() => _VisibilityState();
}

class _VisibilityState extends State<_Visibility> {
  late bool _visible = widget.initiallyVisible;

  @override
  Widget build(BuildContext context) => widget.builder(
    visible: _visible,
    toggle: () => setState(() => _visible = !_visible),
  );
}
