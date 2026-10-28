import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/l10n.dart';
import 'package:nxgt_material/theme.dart';

/// A [MaterialApp] with the package's localizations, around a [Form] that
/// holds [children], validated through [formKey].
Widget formHost(
  List<Widget> children, {
  GlobalKey<FormState>? formKey,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: NxgtMaterialLocalizations.supportedLocales,
    localizationsDelegates: const [
      NxgtMaterialLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(children: children),
        ),
      ),
    ),
  );
}

/// A [MaterialApp] with the package's localizations and a theme built from
/// `ThemePresets.ocean` (so `context.tones` works), around [child] in a
/// [Scaffold].
Widget themedHost(
  Widget child, {
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  bool disableAnimations = false,
}) {
  const preset = ThemePresets.ocean;
  return MaterialApp(
    locale: locale,
    theme: brightness == Brightness.light ? preset.light() : preset.dark(),
    supportedLocales: NxgtMaterialLocalizations.supportedLocales,
    localizationsDelegates: const [
      NxgtMaterialLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: disableAnimations),
      child: app!,
    ),
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
