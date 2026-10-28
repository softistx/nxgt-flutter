import 'package:flutter/material.dart';
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
            WidgetbookTheme(
              name: 'Light',
              data: ThemeData(colorSchemeSeed: Colors.indigo),
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: ThemeData(
                colorSchemeSeed: Colors.indigo,
                brightness: Brightness.dark,
              ),
            ),
          ],
        ),
        ViewportAddon(Viewports.all),
      ],
    );
  }
}
