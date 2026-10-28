import 'package:flutter/widgets.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations.dart';

/// Loads [NxgtMaterialLocalizations] for any locale.
///
/// A locale the package does not translate (anything but `en` and `fr`) gets
/// the English strings instead of no strings at all. [reword] is applied to
/// whatever was loaded, so an app can replace single strings without
/// forking an ARB file; see `NxgtMaterialLocalizationsWrapper`.
class NxgtMaterialLocalizationsDelegate
    extends LocalizationsDelegate<NxgtMaterialLocalizations> {
  /// Creates the delegate; give [reword] to replace some strings.
  const new({this.reword});

  /// Receives the loaded strings and returns the ones to use, usually a
  /// `NxgtMaterialLocalizationsWrapper` subclass that overrides a few getters.
  final NxgtMaterialLocalizations Function(NxgtMaterialLocalizations base)?
  reword;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<NxgtMaterialLocalizations> load(Locale locale) async {
    final supported = NxgtMaterialLocalizations.delegate.isSupported(locale);
    final base = await NxgtMaterialLocalizations.delegate.load(
      supported ? locale : const Locale('en'),
    );
    return reword?.call(base) ?? base;
  }

  @override
  bool shouldReload(NxgtMaterialLocalizationsDelegate old) =>
      old.reword != reword;
}
