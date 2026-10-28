import 'package:flutter/widgets.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations_en.dart';

/// `context.materialL10n`, the strings of the components.
extension NxgtMaterialLocalizationsContext on BuildContext {
  /// The localized strings of `nxgt_material`.
  ///
  /// Falls back to English when the app did not add
  /// `NxgtMaterialLocalizationsDelegate`, so a component never throws for a
  /// missing delegate. In debug builds the first fallback prints one line
  /// naming the delegate to add.
  NxgtMaterialLocalizations get materialL10n {
    final found = Localizations.of<NxgtMaterialLocalizations>(
      this,
      NxgtMaterialLocalizations,
    );
    if (found != null) return found;
    assert(() {
      if (!_warned) {
        _warned = true;
        debugPrint(
          'nxgt_material: no NxgtMaterialLocalizationsDelegate found, '
          'using English. Add it to localizationsDelegates.',
        );
      }
      return true;
    }(), '');
    return NxgtMaterialLocalizationsEn();
  }
}

bool _warned = false;
