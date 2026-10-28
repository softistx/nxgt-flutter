import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'nxgt_material_localizations_en.dart';
import 'nxgt_material_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of NxgtMaterialLocalizations
/// returned by `NxgtMaterialLocalizations.of(context)`.
///
/// Applications need to include `NxgtMaterialLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/nxgt_material_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NxgtMaterialLocalizations.localizationsDelegates,
///   supportedLocales: NxgtMaterialLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the NxgtMaterialLocalizations.supportedLocales
/// property.
abstract class NxgtMaterialLocalizations {
  NxgtMaterialLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NxgtMaterialLocalizations of(BuildContext context) {
    return Localizations.of<NxgtMaterialLocalizations>(
      context,
      NxgtMaterialLocalizations,
    )!;
  }

  static const LocalizationsDelegate<NxgtMaterialLocalizations> delegate =
      _NxgtMaterialLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Primary button of a confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionsConfirm;

  /// No description provided for @actionsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionsCancel;

  /// No description provided for @actionsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionsClose;

  /// No description provided for @actionsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionsSave;

  /// No description provided for @actionsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionsRetry;

  /// No description provided for @actionsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionsClear;

  /// No description provided for @actionsShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get actionsShowMore;

  /// No description provided for @actionsShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get actionsShowLess;

  /// No description provided for @actionsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionsCopy;

  /// No description provided for @actionsCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get actionsCopied;

  /// No description provided for @actionsMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get actionsMoreOptions;

  /// No description provided for @fieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldsRequired;

  /// No description provided for @fieldsInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get fieldsInvalidEmail;

  /// No description provided for @fieldsMinLength.
  ///
  /// In en, this message translates to:
  /// **'Enter at least {count, plural, =1{1 character} other{{count} characters}}'**
  String fieldsMinLength(int count);

  /// No description provided for @fieldsMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Enter at most {count, plural, =1{1 character} other{{count} characters}}'**
  String fieldsMaxLength(int count);

  /// Accessibility label of a progress indicator.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get feedbackLoading;

  /// No description provided for @feedbackEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get feedbackEmptyTitle;

  /// No description provided for @feedbackEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'There is nothing to show for now.'**
  String get feedbackEmptyMessage;

  /// No description provided for @feedbackErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get feedbackErrorTitle;

  /// No description provided for @feedbackErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Try again in a moment.'**
  String get feedbackErrorMessage;

  /// No description provided for @layoutOpenNavigation.
  ///
  /// In en, this message translates to:
  /// **'Open navigation'**
  String get layoutOpenNavigation;

  /// No description provided for @layoutCloseNavigation.
  ///
  /// In en, this message translates to:
  /// **'Close navigation'**
  String get layoutCloseNavigation;
}

class _NxgtMaterialLocalizationsDelegate
    extends LocalizationsDelegate<NxgtMaterialLocalizations> {
  const _NxgtMaterialLocalizationsDelegate();

  @override
  Future<NxgtMaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<NxgtMaterialLocalizations>(
      lookupNxgtMaterialLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_NxgtMaterialLocalizationsDelegate old) => false;
}

NxgtMaterialLocalizations lookupNxgtMaterialLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return NxgtMaterialLocalizationsEn();
    case 'fr':
      return NxgtMaterialLocalizationsFr();
  }

  throw FlutterError(
    'NxgtMaterialLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
