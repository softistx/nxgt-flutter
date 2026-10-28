/// French and English strings of the components, and how an app adds them.
///
/// Add `NxgtMaterialLocalizationsDelegate()` to `localizationsDelegates` and
/// `NxgtMaterialLocalizations.supportedLocales` to `supportedLocales`; read
/// the strings with `context.materialL10n`.
library;

export 'src/l10n/generated/nxgt_material_localizations.dart'
    show NxgtMaterialLocalizations;
export 'src/l10n/localizations_context.dart';
export 'src/l10n/localizations_delegate.dart';
export 'src/l10n/localizations_wrapper.dart';
