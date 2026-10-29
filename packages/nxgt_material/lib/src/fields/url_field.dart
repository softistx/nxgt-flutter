import 'package:flutter/material.dart';
import 'package:nxgt_material/src/fields/text_field_base.dart';
import 'package:nxgt_material/src/fields/url_parse.dart';
import 'package:nxgt_material/src/fields/validators.dart';

/// A text field for a web address.
///
/// Opens the URL keyboard, offers the saved addresses to autofill, never
/// capitalizes or autocorrects, and rejects anything but an http or https
/// address with a localized message. The scheme is optional while typing.
/// Hosts are domain names, including international ones (no bare IP,
/// `localhost` or credentials). The field keeps the text as typed, and
/// [normalize] turns it into a full URL.
class UrlField extends TextFieldBase {
  /// Creates a UrlField.
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

  /// Trims [text] and adds `https://` when it has no scheme.
  ///
  /// Returns `null` when [text] is not an http or https address, as
  /// `Validators.url` reads it: `example.com` becomes `https://example.com`,
  /// `http://example.com/a` is kept, `ftp://x.com` and `localhost` give `null`.
  static String? normalize(String text) => normalizeWebUrl(text);

  @override
  Widget build(BuildContext context) {
    final v = Validators.of(context);
    return buildInput(
      composed: v.compose([if (required) v.required(), v.url(), validator]),
      keyboardType: TextInputType.url,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.url],
      autocorrect: false,
    );
  }
}
