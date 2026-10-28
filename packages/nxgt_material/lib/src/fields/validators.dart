import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:nxgt_material/src/fields/number_parse.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// Validators for `FormField<String>`, with messages in the user's language.
///
/// A validator returns an error message, or `null` when the value is valid,
/// so each one plugs into `TextFormField.validator` or a field of this
/// package. Except [required], they accept an empty value: an optional field
/// is valid until something is typed. Combine them with [compose].
///
/// The messages need the localizations, so build the set from a
/// [BuildContext] (its locale is read once, rebuild to follow a change):
///
/// ```dart
/// final v = Validators.of(context);
/// TextFormField(validator: v.compose([v.required(), v.minLength(3)]));
/// ```
class Validators {
  /// Creates validators that word their messages with [l10n].
  const new(this.l10n);

  /// Creates validators for the locale found above [context].
  ///
  /// Falls back to English when the app did not add
  /// `NxgtMaterialLocalizationsDelegate`, like every component.
  factory of(BuildContext context) => Validators(context.materialL10n);

  /// The strings the messages come from.
  final NxgtMaterialLocalizations l10n;

  static final _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    '[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
    r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
  );
  static final _phone = RegExp(r'^\+?[\d\s().\-]+$');

  /// Fails when the value is `null` or blank.
  FormFieldValidator<String> required() =>
      (value) =>
          value == null || value.trim().isEmpty ? l10n.fieldsRequired : null;

  /// Fails when a non-empty value is not an email address.
  FormFieldValidator<String> email() => (value) {
    final text = value?.trim() ?? '';
    return text.isEmpty || _email.hasMatch(text)
        ? null
        : l10n.fieldsInvalidEmail;
  };

  /// Fails when a non-empty value has fewer than [count] characters.
  FormFieldValidator<String> minLength(int count) => (value) {
    final text = value ?? '';
    return text.isEmpty || text.length >= count
        ? null
        : l10n.fieldsMinLength(count);
  };

  /// Fails when a value has more than [count] characters.
  FormFieldValidator<String> maxLength(int count) =>
      (value) =>
          (value?.length ?? 0) <= count ? null : l10n.fieldsMaxLength(count);

  /// Fails when a non-empty value is not a phone number.
  ///
  /// Accepts an optional leading `+`, digits, spaces, dots, dashes and
  /// parentheses, with 7 to 15 digits (the E.164 range).
  FormFieldValidator<String> phone() => (value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final digits = text.replaceAll(RegExp(r'\D'), '').length;
    return _phone.hasMatch(text) && digits >= 7 && digits <= 15
        ? null
        : l10n.fieldsInvalidPhone;
  };

  /// Fails when a non-empty value is not a number, or is outside
  /// [min]..[max] when given. The text is read as `NumberField.parse` reads it.
  FormFieldValidator<String> number({num? min, num? max}) => (value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = parseNumber(value);
    if (parsed == null) return l10n.fieldsInvalidNumber;
    if (min != null && parsed < min) return l10n.fieldsMinValue(_format(min));
    if (max != null && parsed > max) return l10n.fieldsMaxValue(_format(max));
    return null;
  };

  String _format(num value) =>
      NumberFormat.decimalPattern(l10n.localeName).format(value);

  /// Runs [validators] in order and returns the first message.
  FormFieldValidator<String> compose(
    Iterable<FormFieldValidator<String>?> validators,
  ) {
    final list = validators.nonNulls.toList(growable: false);
    return (value) {
      for (final validator in list) {
        final message = validator(value);
        if (message != null) return message;
      }
      return null;
    };
  }
}
