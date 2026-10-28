import 'package:flutter/widgets.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations_en.dart';

/// `context.materialL10n`, the strings of the components.
extension NxgtMaterialLocalizationsContext on BuildContext {
  /// The localized strings of `nxgt_material`.
  ///
  /// Falls back to English when the app did not add
  /// `NxgtMaterialLocalizationsDelegate`, so a component never throws for a
  /// missing delegate.
  NxgtMaterialLocalizations get materialL10n =>
      Localizations.of<NxgtMaterialLocalizations>(
        this,
        NxgtMaterialLocalizations,
      ) ??
      NxgtMaterialLocalizationsEn();
}
