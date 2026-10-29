import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations.dart';

/// Forwards every string to [base]; subclass it and override the ones an app
/// words differently.
///
/// Always extend this class, never `implements NxgtMaterialLocalizations`: new
/// strings arrive in minor releases, and an `implements` breaks on each one
/// while the wrapper forwards it.
///
/// ```dart
/// class MyStrings extends NxgtMaterialLocalizationsWrapper {
///   new(super.base);
///   @override
///   String get actionsRetry => 'Try again';
/// }
///
/// NxgtMaterialLocalizationsDelegate(reword: MyStrings.new)
/// ```
class NxgtMaterialLocalizationsWrapper extends NxgtMaterialLocalizations {
  /// Wraps [base], keeping its locale.
  new(this.base) : super(base.localeName);

  /// The strings every getter falls back to.
  final NxgtMaterialLocalizations base;

  @override
  String get actionsClose => base.actionsClose;
  @override
  String get actionsRetry => base.actionsRetry;
  @override
  String get actionsShowMore => base.actionsShowMore;
  @override
  String get actionsCopy => base.actionsCopy;
  @override
  String actionsCopyItem(String label) => base.actionsCopyItem(label);
  @override
  String get actionsCopied => base.actionsCopied;
  @override
  String get actionsMoreOptions => base.actionsMoreOptions;
  @override
  String get actionsCancel => base.actionsCancel;
  @override
  String get actionsConfirm => base.actionsConfirm;
  @override
  String get overlaysDiscardTitle => base.overlaysDiscardTitle;
  @override
  String get overlaysDiscardMessage => base.overlaysDiscardMessage;
  @override
  String get overlaysDiscardConfirm => base.overlaysDiscardConfirm;
  @override
  String get fieldsRequired => base.fieldsRequired;
  @override
  String get fieldsInvalidEmail => base.fieldsInvalidEmail;
  @override
  String fieldsMinLength(int count) => base.fieldsMinLength(count);
  @override
  String fieldsMaxLength(int count) => base.fieldsMaxLength(count);
  @override
  String get fieldsInvalidPhone => base.fieldsInvalidPhone;
  @override
  String get fieldsInvalidNumber => base.fieldsInvalidNumber;
  @override
  String fieldsMinValue(String min) => base.fieldsMinValue(min);
  @override
  String fieldsMaxValue(String max) => base.fieldsMaxValue(max);
  @override
  String get fieldsShowPassword => base.fieldsShowPassword;
  @override
  String get fieldsHidePassword => base.fieldsHidePassword;
  @override
  String get feedbackLoading => base.feedbackLoading;
  @override
  String get feedbackEmptyTitle => base.feedbackEmptyTitle;
  @override
  String get feedbackEmptyMessage => base.feedbackEmptyMessage;
  @override
  String get feedbackErrorTitle => base.feedbackErrorTitle;
  @override
  String get feedbackErrorMessage => base.feedbackErrorMessage;
  @override
  String get feedbackToneInfo => base.feedbackToneInfo;
  @override
  String get feedbackToneSuccess => base.feedbackToneSuccess;
  @override
  String get feedbackToneWarning => base.feedbackToneWarning;
  @override
  String get feedbackToneError => base.feedbackToneError;
  @override
  String get layoutOpenNavigation => base.layoutOpenNavigation;
  @override
  String get layoutCloseNavigation => base.layoutCloseNavigation;
  @override
  String get layoutNavigation => base.layoutNavigation;
  @override
  String displayCount(int count) => base.displayCount(count);
  @override
  String get displayTrendUp => base.displayTrendUp;
  @override
  String get displayTrendDown => base.displayTrendDown;
  @override
  String get displayTrendFlat => base.displayTrendFlat;
  @override
  String get displayPresenceOnline => base.displayPresenceOnline;
  @override
  String get displayPresenceAway => base.displayPresenceAway;
  @override
  String get displayPresenceBusy => base.displayPresenceBusy;
  @override
  String get displayPresenceOffline => base.displayPresenceOffline;
  @override
  String get fieldsSelectClear => base.fieldsSelectClear;
  @override
  String get fieldsSelectSearch => base.fieldsSelectSearch;
  @override
  String get fieldsSelectNoResults => base.fieldsSelectNoResults;
  @override
  String get collectionsSearchClear => base.collectionsSearchClear;
}
