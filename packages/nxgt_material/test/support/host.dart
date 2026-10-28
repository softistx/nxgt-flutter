import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nxgt_material/l10n.dart';

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
