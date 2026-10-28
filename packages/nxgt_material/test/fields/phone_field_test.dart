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
    PhoneField field, {
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
    await pump(tester, const PhoneField(label: 'Phone'));

    expect(find.text('Phone'), findsOneWidget);
    expect(input(tester).keyboardType, TextInputType.phone);
    expect(input(tester).autofillHints, const [AutofillHints.telephoneNumber]);
    expect(input(tester).textInputAction, TextInputAction.next);
  });

  testWidgets('accepts a valid value and an empty optional one', (
    tester,
  ) async {
    await pump(
      tester,
      const PhoneField(label: 'Phone', initialValue: '+33 6 12 34 56 78'),
    );
    expect(key.currentState!.validate(), isTrue);

    await pump(tester, const PhoneField(label: 'Phone'));
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('shows the localized error for an invalid value', (tester) async {
    await pump(tester, const PhoneField(label: 'Phone', initialValue: '12'));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Enter a valid phone number'), findsOneWidget);

    await pump(
      tester,
      const PhoneField(label: 'Phone', initialValue: '12'),
      locale: const Locale('fr'),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(
      find.text('Saisissez un numéro de téléphone valide'),
      findsOneWidget,
    );
  });

  testWidgets('required rejects an empty value first', (tester) async {
    await pump(tester, const PhoneField(label: 'Phone', required: true));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('runs the extra validator after the built-in ones', (
    tester,
  ) async {
    await pump(
      tester,
      PhoneField(
        label: 'Phone',
        initialValue: '+33 6 12 34 56 78',
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
      PhoneField(
        label: 'Phone',
        onChanged: (v) => changed = v,
        onSaved: (v) => saved = v,
        onFieldSubmitted: (v) => submitted = v,
      ),
    );

    await tester.enterText(find.byType(EditableText), '+33 6 12 34 56 78');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    key.currentState!.save();

    expect(changed, '+33 6 12 34 56 78');
    expect(saved, '+33 6 12 34 56 78');
    expect(submitted, '+33 6 12 34 56 78');
  });

  testWidgets('refuses characters that are not part of a number', (
    tester,
  ) async {
    await pump(tester, const PhoneField(label: 'Phone'));

    await tester.enterText(find.byType(EditableText), '06 ab-12.(3)+x');

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '06 -12.(3)+',
    );
  });

  group('semantics', () {
    testWidgets('is a labelled text field', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const PhoneField(label: 'Phone'));

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Phone',
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
      await pump(tester, const PhoneField(label: 'Phone', initialValue: '12'));
      key.currentState!.validate();
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Phone',
          hint: 'Enter a valid phone number',
          isTextField: true,
          validationResult: SemanticsValidationResult.invalid,
        ),
      );
      handle.dispose();
    });

    testWidgets('is not focusable when disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const PhoneField(label: 'Phone', enabled: false));

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(label: 'Phone', isTextField: true, hasEnabledState: true),
      );
      handle.dispose();
    });
  });
}
