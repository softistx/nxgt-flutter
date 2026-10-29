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

  /// Tooltip and screen reader label of a close button, such as the one of a dismissible alert or toast.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionsClose;

  /// Label of the button that tries a failed action or load again.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionsRetry;

  /// Label of the button that loads the next page of a list.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get actionsShowMore;

  /// Label of the button that copies a value to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionsCopy;

  /// Label of the copy button after the value was copied, and what a screen reader announces.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get actionsCopied;

  /// Tooltip and screen reader label of the arrow button of a split button that opens its menu.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get actionsMoreOptions;

  /// Error shown under a required field that is empty.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldsRequired;

  /// Error shown under an email field whose value is not an email address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get fieldsInvalidEmail;

  /// Error shown under a field whose text is shorter than its minimum length.
  ///
  /// In en, this message translates to:
  /// **'Enter at least {count, plural, =1{1 character} other{{count} characters}}'**
  String fieldsMinLength(int count);

  /// Error shown under a field whose text is longer than its maximum length.
  ///
  /// In en, this message translates to:
  /// **'Enter at most {count, plural, =1{1 character} other{{count} characters}}'**
  String fieldsMaxLength(int count);

  /// Error shown under a phone field whose value is not a phone number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get fieldsInvalidPhone;

  /// Error shown under a number field whose value is not a number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get fieldsInvalidNumber;

  /// Error shown under a number field whose value is below its minimum.
  ///
  /// In en, this message translates to:
  /// **'Enter a value of at least {min}'**
  String fieldsMinValue(String min);

  /// Error shown under a number field whose value is above its maximum.
  ///
  /// In en, this message translates to:
  /// **'Enter a value of at most {max}'**
  String fieldsMaxValue(String max);

  /// Tooltip and screen reader label of the button that reveals the password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get fieldsShowPassword;

  /// Tooltip and screen reader label of the button that hides the password.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get fieldsHidePassword;

  /// Accessibility label of a progress indicator.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get feedbackLoading;

  /// Title of an empty state when the app gives none.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get feedbackEmptyTitle;

  /// Message of an empty state when the app gives none.
  ///
  /// In en, this message translates to:
  /// **'There is nothing to show for now.'**
  String get feedbackEmptyMessage;

  /// Title of an error state when the app gives none.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get feedbackErrorTitle;

  /// Message of an error state when the app gives none.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Try again in a moment.'**
  String get feedbackErrorMessage;

  /// Spoken before the message of an info alert or toast, so the tone is not carried by colour alone.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get feedbackToneInfo;

  /// Spoken before the message of a success alert or toast.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get feedbackToneSuccess;

  /// Spoken before the message of a warning alert or toast.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get feedbackToneWarning;

  /// Spoken before the message of an error alert or toast.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get feedbackToneError;

  /// Tooltip and screen reader label of the menu button that opens the navigation drawer.
  ///
  /// In en, this message translates to:
  /// **'Open navigation'**
  String get layoutOpenNavigation;

  /// Screen reader label of the action that closes the navigation drawer.
  ///
  /// In en, this message translates to:
  /// **'Close navigation'**
  String get layoutCloseNavigation;

  /// Label of the navigation region of the adaptive shell (bar, rail or drawer), read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get layoutNavigation;

  /// Screen reader text of a count badge: how many items the count stands for.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String displayCount(int count);

  /// Screen reader text of an avatar's presence dot: the person is available now.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get displayPresenceOnline;

  /// Screen reader text of an avatar's presence dot: the person is signed in but away.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get displayPresenceAway;

  /// Screen reader text of an avatar's presence dot: the person asked not to be disturbed.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get displayPresenceBusy;

  /// Screen reader text of an avatar's presence dot: the person is not signed in.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get displayPresenceOffline;
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
