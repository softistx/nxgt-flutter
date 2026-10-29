import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/l10n.dart';
import 'package:nxgt_material/theme.dart';

const _delegates = <LocalizationsDelegate<dynamic>>[
  NxgtMaterialLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _app({
  required Widget home,
  required Locale locale,
  ThemeData? theme,
  TransitionBuilder? builder,
}) => MaterialApp(
  locale: locale,
  theme: theme,
  supportedLocales: NxgtMaterialLocalizations.supportedLocales,
  localizationsDelegates: _delegates,
  builder: builder,
  home: home,
);

/// A [MaterialApp] with the package's localizations, around a [Form] that
/// holds [children], validated through [formKey].
Widget formHost(
  List<Widget> children, {
  GlobalKey<FormState>? formKey,
  Locale locale = const Locale('en'),
}) => _app(
  locale: locale,
  home: Scaffold(
    body: SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(children: children),
      ),
    ),
  ),
);

/// A [MaterialApp] with the package's localizations and a theme built from
/// `ThemePresets.ocean`, around [child] in a [Scaffold]. [plainTheme] uses a
/// bare `ThemeData` instead, to check the fallbacks of components. A
/// [direction] forces the text direction of the whole app, routes included.
Widget themedHost(
  Widget child, {
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  bool disableAnimations = false,
  bool plainTheme = false,
  TextDirection? direction,
}) {
  const preset = ThemePresets.ocean;
  return _app(
    locale: locale,
    theme: plainTheme
        ? ThemeData()
        : (brightness == Brightness.light ? preset.light() : preset.dark()),
    builder: (context, app) {
      final media = MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: app!,
      );
      return direction == null
          ? media
          : Directionality(textDirection: direction, child: media);
    },
    home: Scaffold(body: child),
  );
}

extension PumpApp on WidgetTester {
  /// Pumps [app], then one more frame so the localizations have loaded.
  Future<void> pumpApp(Widget app) async {
    await pumpWidget(app);
    await pump();
  }
}
