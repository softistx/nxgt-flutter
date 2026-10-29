import 'package:flutter/material.dart';
import 'package:nxgt_material/l10n.dart';

/// The first and last date a date field accepts. Internal, not exported.
///
/// Owns the defaults (1 January 1900 to 31 December 2100), the midnight
/// normalisation, the clamp and the wording of the out-of-range errors. A
/// reversed pair is an assertion failure; a release build reads it as
/// `last == first`.
class DateBounds {
  /// Normalises [first] and [last] to midnight, with the default for `null`.
  new(DateTime? first, DateTime? last)
    : assert(
        first == null ||
            last == null ||
            !DateUtils.dateOnly(last).isBefore(DateUtils.dateOnly(first)),
        'lastDate must not be before firstDate',
      ),
      first = DateUtils.dateOnly(first ?? DateTime(1900)),
      last = _later(
        DateUtils.dateOnly(last ?? DateTime(2100, 12, 31)),
        DateUtils.dateOnly(first ?? DateTime(1900)),
      );

  /// The earliest accepted date.
  final DateTime first;

  /// The latest accepted date.
  final DateTime last;

  static DateTime _later(DateTime a, DateTime b) => a.isBefore(b) ? b : a;

  /// [date] moved into the bounds.
  DateTime clamp(DateTime date) {
    if (date.isBefore(first)) return first;
    if (date.isAfter(last)) return last;
    return date;
  }

  /// The error for a value spanning [start] to [end], or `null` when it is in
  /// the bounds. The bound is worded by [format].
  String? error(
    NxgtMaterialLocalizations l10n,
    DateTime start,
    DateTime end,
    String Function(DateTime date) format,
  ) {
    if (start.isBefore(first)) return l10n.datesBefore(format(first));
    if (end.isAfter(last)) return l10n.datesAfter(format(last));
    return null;
  }
}
