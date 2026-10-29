// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'nxgt_material_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NxgtMaterialLocalizationsEn extends NxgtMaterialLocalizations {
  NxgtMaterialLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actionsClose => 'Close';

  @override
  String get actionsRetry => 'Retry';

  @override
  String get actionsShowMore => 'Show more';

  @override
  String get actionsCopy => 'Copy';

  @override
  String actionsCopyItem(String label) {
    return 'Copy $label';
  }

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
  String get fieldsInvalidPhone => 'Enter a valid phone number';

  @override
  String get fieldsInvalidNumber => 'Enter a valid number';

  @override
  String fieldsMinValue(String min) {
    return 'Enter a value of at least $min';
  }

  @override
  String fieldsMaxValue(String max) {
    return 'Enter a value of at most $max';
  }

  @override
  String get fieldsShowPassword => 'Show password';

  @override
  String get fieldsHidePassword => 'Hide password';

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
  String get feedbackToneInfo => 'Information';

  @override
  String get feedbackToneSuccess => 'Success';

  @override
  String get feedbackToneWarning => 'Warning';

  @override
  String get feedbackToneError => 'Error';

  @override
  String get layoutOpenNavigation => 'Open navigation';

  @override
  String get layoutCloseNavigation => 'Close navigation';

  @override
  String get layoutNavigation => 'Navigation';

  @override
  String displayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get displayTrendUp => 'up';

  @override
  String get displayTrendDown => 'down';

  @override
  String get displayTrendFlat => 'unchanged';

  @override
  String get displayPresenceOnline => 'Online';

  @override
  String get displayPresenceAway => 'Away';

  @override
  String get displayPresenceBusy => 'Busy';

  @override
  String get displayPresenceOffline => 'Offline';

  @override
  String get actionsCancel => 'Cancel';

  @override
  String get actionsConfirm => 'Confirm';

  @override
  String get overlaysDiscardTitle => 'Discard changes?';

  @override
  String get overlaysDiscardMessage =>
      'Your changes have not been saved. If you close now, they are lost.';

  @override
  String get overlaysDiscardConfirm => 'Discard';

  @override
  String get fieldsSelectClear => 'Clear selection';

  @override
  String get fieldsSelectSearch => 'Search';

  @override
  String get fieldsSelectNoResults => 'No results';

  @override
  String get collectionsSearchHint => 'Search';

  @override
  String get collectionsSearchClear => 'Clear search';

  @override
  String collectionsLoadedMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more loaded',
      one: '1 more loaded',
    );
    return '$_temp0';
  }

  @override
  String get collectionsSortBy => 'Sort by';

  @override
  String collectionsSortedAscending(String column) {
    return '$column, sorted ascending';
  }

  @override
  String collectionsSortedDescending(String column) {
    return '$column, sorted descending';
  }
}
