final _number = RegExp(r'^-?\d+([.,]\d+)?$|^-?[.,]\d+$');

/// Parses what a user typed in a number field.
///
/// A comma or a point is the decimal separator (French keyboards have a
/// comma); there are no thousands separators, so `1,234` is 1.234 and
/// `1,234.5` is malformed. Surrounding spaces are ignored. Hexadecimal and
/// exponent forms (`0x1A`, `1e3`) are rejected. Returns `null` for an empty
/// or malformed text.
///
/// Internal: apps use `NumberField.parse`, which is the one public parser.
num? parseNumber(String? text) {
  final trimmed = text?.trim();
  if (trimmed == null || !_number.hasMatch(trimmed)) return null;
  return num.tryParse(trimmed.replaceAll(',', '.'));
}
