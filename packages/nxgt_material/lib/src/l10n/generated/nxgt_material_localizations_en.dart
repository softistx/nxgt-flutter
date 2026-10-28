// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'nxgt_material_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NxgtMaterialLocalizationsEn extends NxgtMaterialLocalizations {
  NxgtMaterialLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actionsConfirm => 'Confirm';

  @override
  String get actionsCancel => 'Cancel';

  @override
  String get actionsClose => 'Close';

  @override
  String get actionsSave => 'Save';

  @override
  String get actionsRetry => 'Retry';

  @override
  String get actionsClear => 'Clear';

  @override
  String get actionsShowMore => 'Show more';

  @override
  String get actionsShowLess => 'Show less';

  @override
  String get actionsCopy => 'Copy';

  @override
  String get actionsCopied => 'Copied';

  @override
  String get actionsMoreOptions => 'More options';

  @override
  String get fieldsRequired => 'This field is required';

  @override
  String get fieldsInvalidEmail => 'Enter a valid email address';

  @override
  String fieldsMinLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count characters',
      one: '1 character',
    );
    return 'Enter at least $_temp0';
  }

  @override
  String fieldsMaxLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count characters',
      one: '1 character',
    );
    return 'Enter at most $_temp0';
  }

  @override
  String get feedbackLoading => 'Loading';

  @override
  String get feedbackEmptyTitle => 'Nothing here yet';

  @override
  String get feedbackEmptyMessage => 'There is nothing to show for now.';

  @override
  String get feedbackErrorTitle => 'Something went wrong';

  @override
  String get feedbackErrorMessage =>
      'An error occurred. Try again in a moment.';

  @override
  String get layoutOpenNavigation => 'Open navigation';

  @override
  String get layoutCloseNavigation => 'Close navigation';
}
