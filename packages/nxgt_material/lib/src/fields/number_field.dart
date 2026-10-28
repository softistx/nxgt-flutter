import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nxgt_material/src/fields/field_input.dart';
import 'package:nxgt_material/src/fields/number_parse.dart';
import 'package:nxgt_material/src/fields/validators.dart';

/// A text field for a number, with an optional range.
///
/// Opens the numeric keypad and refuses any character that cannot be part of
/// a number. A comma is accepted as the decimal separator, since French
/// keyboards have no dot on the numeric keypad: read the value with
/// [NumberField.parse], not `num.parse`.
class NumberField extends StatelessWidget {
  /// Creates a NumberField.
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
    this.min,
    this.max,
    this.allowDecimal = false,
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

  /// The smallest accepted value; a smaller one is an error. A negative
  /// sign is accepted only when this is `null` or below zero.
  final num? min;

  /// The largest accepted value; a larger one is an error.
  final num? max;

  /// Whether the value may have decimals.
  final bool allowDecimal;

  /// The keyboard action button.
  final TextInputAction textInputAction;

  /// The number in [text], or `null` when it is empty or malformed.
  ///
  /// The strict rule the field and `Validators.number` share: a comma or a
  /// point is the decimal separator, there are no thousands separators
  /// (`1,234` is 1.234 and `1,234.5` is refused), surrounding spaces are
  /// ignored, and hexadecimal and exponent forms (`0x1A`, `1e3`) are refused.
  static num? parse(String? text) => parseNumber(text);

  @override
  Widget build(BuildContext context) {
    final v = Validators.of(context);
    final signed = min == null || min! < 0;
    final sign = signed ? '-?' : '';
    final fraction = allowDecimal ? r'[.,]?\d*' : '';
    final shape = RegExp('^$sign\\d*$fraction\$');
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
      validator: v.compose([
        if (required) v.required(),
        v.number(min: min, max: max),
        validator,
      ]),
      keyboardType: TextInputType.numberWithOptions(
        signed: signed,
        decimal: allowDecimal,
      ),
      textInputAction: textInputAction,
      inputFormatters: [
        TextInputFormatter.withFunction(
          (old, value) => shape.hasMatch(value.text) ? value : old,
        ),
      ],
    );
  }
}
