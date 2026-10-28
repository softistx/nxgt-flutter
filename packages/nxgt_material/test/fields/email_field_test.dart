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
    EmailField field, {
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
    await pump(tester, const EmailField(label: 'Email'));

    expect(find.text('Email'), findsOneWidget);
    expect(input(tester).keyboardType, TextInputType.emailAddress);
    expect(input(tester).autofillHints, const [AutofillHints.email]);
    expect(input(tester).textInputAction, TextInputAction.next);
  });

  testWidgets('accepts a valid value and an empty optional one', (
    tester,
  ) async {
    await pump(
      tester,
      const EmailField(label: 'Email', initialValue: 'ada@example.com'),
    );
    expect(key.currentState!.validate(), isTrue);

    await pump(tester, const EmailField(label: 'Email'));
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('shows the localized error for an invalid value', (tester) async {
    await pump(
      tester,
      const EmailField(label: 'Email', initialValue: 'not-an-email'),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await pump(
      tester,
      const EmailField(label: 'Email', initialValue: 'not-an-email'),
      locale: const Locale('fr'),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(find.text('Saisissez une adresse e-mail valide'), findsOneWidget);
  });

  testWidgets('required rejects an empty value first', (tester) async {
    await pump(tester, const EmailField(label: 'Email', required: true));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('runs the extra validator after the built-in ones', (
    tester,
  ) async {
    await pump(
      tester,
      EmailField(
        label: 'Email',
        initialValue: 'ada@example.com',
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
      EmailField(
        label: 'Email',
        onChanged: (v) => changed = v,
        onSaved: (v) => saved = v,
        onFieldSubmitted: (v) => submitted = v,
      ),
    );

    await tester.enterText(find.byType(EditableText), 'ada@example.com');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    key.currentState!.save();

    expect(changed, 'ada@example.com');
    expect(saved, 'ada@example.com');
    expect(submitted, 'ada@example.com');
  });

  group('semantics', () {
    testWidgets('is a labelled text field', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const EmailField(label: 'Email'));

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Email',
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
        const EmailField(label: 'Email', initialValue: 'not-an-email'),
      );
      key.currentState!.validate();
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Email',
          hint: 'Enter a valid email address',
          isTextField: true,
          validationResult: SemanticsValidationResult.invalid,
        ),
      );
      handle.dispose();
    });

    testWidgets('is not focusable when disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const EmailField(label: 'Email', enabled: false));

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(label: 'Email', isTextField: true, hasEnabledState: true),
      );
      handle.dispose();
    });
  });
}
