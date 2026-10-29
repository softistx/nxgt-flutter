// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'nxgt_material_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class NxgtMaterialLocalizationsFr extends NxgtMaterialLocalizations {
  NxgtMaterialLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get actionsClose => 'Fermer';

  @override
  String get actionsRetry => 'Réessayer';

  @override
  String get actionsShowMore => 'Afficher plus';

  @override
  String get actionsCopy => 'Copier';

  @override
  String actionsCopyItem(String label) {
    return 'Copier « $label »';
  }

  @override
  String get actionsCopied => 'Copié';

  @override
  String get actionsMoreOptions => 'Plus d’options';

  @override
  String get fieldsRequired => 'Ce champ est obligatoire';

  @override
  String get fieldsInvalidEmail => 'Saisissez une adresse e-mail valide';

  @override
  String fieldsMinLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caractères',
      one: '1 caractère',
    );
    return 'Saisissez au moins $_temp0';
  }

  @override
  String fieldsMaxLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caractères',
      one: '1 caractère',
    );
    return 'Saisissez au plus $_temp0';
  }

  @override
  String get fieldsInvalidPhone => 'Saisissez un numéro de téléphone valide';

  @override
  String get fieldsInvalidNumber => 'Saisissez un nombre valide';

  @override
  String fieldsMinValue(String min) {
    return 'Saisissez une valeur d’au moins $min';
  }

  @override
  String fieldsMaxValue(String max) {
    return 'Saisissez une valeur d’au plus $max';
  }

  @override
  String get fieldsShowPassword => 'Afficher le mot de passe';

  @override
  String get fieldsHidePassword => 'Masquer le mot de passe';

  @override
  String get feedbackLoading => 'Chargement';

  @override
  String get feedbackEmptyTitle => 'Rien pour l’instant';

  @override
  String get feedbackEmptyMessage => 'Il n’y a rien à afficher pour le moment.';

  @override
  String get feedbackErrorTitle => 'Une erreur est survenue';

  @override
  String get feedbackErrorMessage =>
      'Une erreur s’est produite. Réessayez dans un instant.';

  @override
  String get feedbackToneInfo => 'Information';

  @override
  String get feedbackToneSuccess => 'Succès';

  @override
  String get feedbackToneWarning => 'Attention';

  @override
  String get feedbackToneError => 'Erreur';

  @override
  String get layoutOpenNavigation => 'Ouvrir la navigation';

  @override
  String get layoutCloseNavigation => 'Fermer la navigation';

  @override
  String get layoutNavigation => 'Navigation';

  @override
  String displayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String get displayTrendUp => 'en hausse';

  @override
  String get displayTrendDown => 'en baisse';

  @override
  String get displayTrendFlat => 'stable';

  @override
  String get displayPresenceOnline => 'En ligne';

  @override
  String get displayPresenceAway => 'Absent';

  @override
  String get displayPresenceBusy => 'Occupé';

  @override
  String get displayPresenceOffline => 'Hors ligne';
}
