import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/l10n.dart';

class _Reworded extends NxgtMaterialLocalizationsWrapper {
  new(super.base);

  @override
  String get actionsRetry => 'Try again';
}

Future<NxgtMaterialLocalizations> _pump(
  WidgetTester tester, {
  required Locale locale,
  NxgtMaterialLocalizationsDelegate delegate =
      const NxgtMaterialLocalizationsDelegate(),
}) async {
  late NxgtMaterialLocalizations strings;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: NxgtMaterialLocalizations.supportedLocales,
      localizationsDelegates: [
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          strings = context.materialL10n;
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return strings;
}

void main() {
  testWidgets('English resolves', (tester) async {
    final s = await _pump(tester, locale: const Locale('en'));
    expect(s.localeName, 'en');
    expect(s.actionsCancel, 'Cancel');
    expect(s.fieldsMinLength(1), 'Enter at least 1 character');
    expect(s.fieldsMinLength(3), 'Enter at least 3 characters');
    expect(s.fieldsMaxLength(2), 'Enter at most 2 characters');
  });

  testWidgets('French resolves', (tester) async {
    final s = await _pump(tester, locale: const Locale('fr'));
    expect(s.localeName, 'fr');
    expect(s.actionsCancel, 'Annuler');
    expect(s.fieldsMinLength(1), 'Saisissez au moins 1 caractère');
    expect(s.fieldsMaxLength(5), 'Saisissez au plus 5 caractères');
  });

  testWidgets('every string is translated, none is empty', (tester) async {
    final en = await _pump(tester, locale: const Locale('en'));
    final fr = await _pump(tester, locale: const Locale('fr'));
    final enAll = _all(en);
    final frAll = _all(fr);
    expect(enAll.length, frAll.length);
    for (var i = 0; i < enAll.length; i++) {
      expect(enAll[i], isNotEmpty);
      expect(frAll[i], isNotEmpty);
    }
  });

  testWidgets('an unsupported locale falls back to English', (tester) async {
    final s = await _pump(tester, locale: const Locale('de'));
    expect(s.localeName, 'en');
    expect(s.actionsRetry, 'Retry');
  });

  testWidgets('an override wins and keeps the other strings', (tester) async {
    final s = await _pump(
      tester,
      locale: const Locale('fr'),
      delegate: const NxgtMaterialLocalizationsDelegate(reword: _Reworded.new),
    );
    expect(s.actionsRetry, 'Try again');
    expect(s.actionsCancel, 'Annuler');
    expect(s.localeName, 'fr');
    expect(
      _all(s).length,
      _all(await _pump(tester, locale: const Locale('en'))).length,
    );
  });

  testWidgets('without the delegate the accessor answers in English', (
    tester,
  ) async {
    late NxgtMaterialLocalizations strings;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            strings = context.materialL10n;
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(strings.actionsClose, 'Close');
  });

  test('the delegate reloads only when the override changes', () {
    const a = NxgtMaterialLocalizationsDelegate();
    expect(a.shouldReload(const NxgtMaterialLocalizationsDelegate()), isFalse);
    expect(
      a.shouldReload(
        const NxgtMaterialLocalizationsDelegate(reword: _Reworded.new),
      ),
      isTrue,
    );
  });
}

/// Every string of [s], so two locales can be compared for completeness.
List<String> _all(NxgtMaterialLocalizations s) => [
  s.actionsConfirm,
  s.actionsCancel,
  s.actionsClose,
  s.actionsSave,
  s.actionsRetry,
  s.actionsClear,
  s.actionsShowMore,
  s.actionsShowLess,
  s.fieldsRequired,
  s.fieldsInvalidEmail,
  s.fieldsMinLength(2),
  s.fieldsMaxLength(2),
  s.feedbackLoading,
  s.feedbackEmptyTitle,
  s.feedbackEmptyMessage,
  s.feedbackErrorTitle,
  s.feedbackErrorMessage,
  s.layoutOpenNavigation,
  s.layoutCloseNavigation,
];
