import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nxgt_material/l10n.dart';
import 'package:nxgt_material/theme.dart';
import 'package:nxgt_widgetbook/main.directories.g.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() => runApp(const WidgetbookApp());

/// The catalogue of `nxgt_material`. Use cases live in `lib/` next to this
/// file (`lib/<category>/<component>.usecase.dart`); run
/// `melos run gen` to regenerate `main.directories.g.dart`.
@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  /// Creates the catalogue.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            for (final preset in ThemePresets.all) ...[
              WidgetbookTheme(
                name: '${preset.displayName} light',
                data: preset.light(),
              ),
              WidgetbookTheme(
                name: '${preset.displayName} dark',
                data: preset.dark(),
              ),
            ],
          ],
        ),
        LocalizationAddon(
          locales: NxgtMaterialLocalizations.supportedLocales,
          localizationsDelegates: [
            const NxgtMaterialLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
        ViewportAddon(Viewports.all),
      ],
    );
  }
}
