import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/fields.dart';

import '../support/host.dart';

void main() {
  late GlobalKey<FormState> key;
  setUp(() => key = GlobalKey<FormState>());

  Future<void> pump(
    WidgetTester tester,
    UrlField field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  EditableText input(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText));

  testWidgets('shows its label and sets the keyboard, autofill and action', (
    tester,
  ) async {
    await pump(tester, const UrlField(label: 'Website'));

    expect(find.text('Website'), findsOneWidget);
    expect(input(tester).keyboardType, TextInputType.url);
    expect(input(tester).autofillHints, const [AutofillHints.url]);
    expect(input(tester).textInputAction, TextInputAction.next);
    expect(input(tester).textCapitalization, TextCapitalization.none);
    expect(input(tester).autocorrect, isFalse);
  });

  group('UrlField.normalize', () {
    const table = <String, String?>{
      'example.com': 'https://example.com',
      '  example.com/a?q=1  ': 'https://example.com/a?q=1',
      'https://example.com': 'https://example.com',
      'http://example.com/path': 'http://example.com/path',
      'HTTP://Example.COM': 'HTTP://Example.COM',
      'HTTPS://Example.com': 'HTTPS://Example.com',
      'ftp://x.com': null,
      'localhost': null,
      'http://': null,
      'not a url': null,
      '': null,
      '   ': null,
    };
    for (final entry in table.entries) {
      test('"${entry.key}" gives ${entry.value}', () {
        expect(UrlField.normalize(entry.key), entry.value);
      });
    }
  });

  testWidgets('accepts a valid value and an empty optional one', (
    tester,
  ) async {
    await pump(
      tester,
      const UrlField(label: 'Website', initialValue: 'https://example.com'),
    );
    expect(key.currentState!.validate(), isTrue);

    await pump(tester, const UrlField(label: 'Website'));
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('shows the localized error for an invalid value', (tester) async {
    await pump(
      tester,
      const UrlField(label: 'Website', initialValue: 'not a url'),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Enter a valid web address'), findsOneWidget);

    await pump(
      tester,
      const UrlField(label: 'Website', initialValue: 'not a url'),
      locale: const Locale('fr'),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(find.text('Saisissez une adresse web valide'), findsOneWidget);
  });

  testWidgets('required rejects an empty value first', (tester) async {
    await pump(tester, const UrlField(label: 'Website', required: true));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('runs the extra validator after the built-in ones', (
    tester,
  ) async {
    await pump(
      tester,
      UrlField(
        label: 'Website',
        initialValue: 'https://example.com',
        validator: (_) => 'Nope',
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Nope'), findsOneWidget);
  });

  testWidgets('reports edits, saves and submits', (tester) async {
    String? changed;
    String? saved;
    String? submitted;
    await pump(
      tester,
      UrlField(
        label: 'Website',
        onChanged: (v) => changed = v,
        onSaved: (v) => saved = v,
        onFieldSubmitted: (v) => submitted = v,
      ),
    );

    await tester.enterText(find.byType(EditableText), 'https://example.com');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    key.currentState!.save();

    expect(changed, 'https://example.com');
    expect(saved, 'https://example.com');
    expect(submitted, 'https://example.com');
  });

  group('semantics', () {
    testWidgets('is a labelled text field', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const UrlField(label: 'Website'));

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Website',
          isTextField: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('announces the error with the field and marks it invalid', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const UrlField(label: 'Website', initialValue: 'not a url'),
      );
      key.currentState!.validate();
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Website',
          hint: 'Enter a valid web address',
          isTextField: true,
          validationResult: SemanticsValidationResult.invalid,
        ),
      );
      handle.dispose();
    });

    testWidgets('is not focusable when disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const UrlField(label: 'Website', enabled: false));

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(label: 'Website', isTextField: true, hasEnabledState: true),
      );
      handle.dispose();
    });
  });
}
