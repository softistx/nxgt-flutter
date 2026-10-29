import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nxgt_material/src/fields/number_parse.dart';
import 'package:nxgt_material/src/fields/text_field_base.dart';
import 'package:nxgt_material/src/fields/validators.dart';

/// A text field for a number, with an optional range.
///
/// Opens the numeric keypad and refuses any character that cannot be part of
/// a number. A comma is accepted as the decimal separator, since French
/// keyboards have no dot on the numeric keypad: read the value with
/// [NumberField.parse], not `num.parse`.
class NumberField extends TextFieldBase {
  /// Creates a NumberField.
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
    this.min,
    this.max,
    this.allowDecimal = false,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

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
    return buildInput(
      composed: v.compose([
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
