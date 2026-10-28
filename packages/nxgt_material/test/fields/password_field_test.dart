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
    PasswordField field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  EditableText input(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText));

  testWidgets('hides the text, never corrects it, hints a password', (
    tester,
  ) async {
    await pump(tester, const PasswordField(label: 'Password'));

    expect(input(tester).obscureText, isTrue);
    expect(input(tester).autocorrect, isFalse);
    expect(input(tester).enableSuggestions, isFalse);
    expect(input(tester).keyboardType, TextInputType.visiblePassword);
    expect(input(tester).autofillHints, const [AutofillHints.password]);
    expect(input(tester).textInputAction, TextInputAction.done);
  });

  testWidgets('hints a new password for a sign-up', (tester) async {
    await pump(
      tester,
      const PasswordField(label: 'Password', newPassword: true),
    );

    expect(input(tester).autofillHints, const [AutofillHints.newPassword]);
  });

  testWidgets('the toggle shows and hides the text', (tester) async {
    await pump(
      tester,
      const PasswordField(label: 'Password', initialValue: 'x'),
    );
    expect(input(tester).obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(input(tester).obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);

    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(input(tester).obscureText, isTrue);
  });

  testWidgets('can start visible', (tester) async {
    await pump(
      tester,
      const PasswordField(label: 'Password', initiallyVisible: true),
    );

    expect(input(tester).obscureText, isFalse);
  });

  testWidgets('the toggle label follows the locale', (tester) async {
    await pump(
      tester,
      const PasswordField(label: 'Mot de passe'),
      locale: const Locale('fr'),
    );

    expect(find.byTooltip('Afficher le mot de passe'), findsOneWidget);
  });

  testWidgets('the toggle is inert when the field is disabled', (tester) async {
    await pump(tester, const PasswordField(label: 'Password', enabled: false));

    await tester.tap(find.byTooltip('Show password'), warnIfMissed: false);
    await tester.pump();
    expect(input(tester).obscureText, isTrue);
  });

  testWidgets('validates required and minLength, then the extra one', (
    tester,
  ) async {
    await pump(tester, const PasswordField(label: 'Password', required: true));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);

    await pump(
      tester,
      const PasswordField(label: 'Password', minLength: 8, initialValue: 'abc'),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Enter at least 8 characters'), findsOneWidget);

    await pump(
      tester,
      PasswordField(
        label: 'Password',
        minLength: 3,
        initialValue: 'abc',
        validator: (_) => 'Too common',
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Too common'), findsOneWidget);
  });

  testWidgets('accepts a long enough password', (tester) async {
    await pump(
      tester,
      const PasswordField(label: 'Password', minLength: 3, initialValue: 'abc'),
    );
    expect(key.currentState!.validate(), isTrue);
  });

  group('semantics', () {
    testWidgets('is a labelled, obscured text field', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const PasswordField(label: 'Password'));

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Password',
          isTextField: true,
          isObscured: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('is no longer obscured once shown', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const PasswordField(label: 'Password', initiallyVisible: true),
      );

      final data = tester
          .getSemantics(find.byType(TextFormField))
          .getSemanticsData();
      expect(data.flagsCollection.isObscured, isFalse);
      handle.dispose();
    });

    testWidgets('the toggle is a labelled 48 dp button with a state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const PasswordField(label: 'Password'));

      final toggle = find.byTooltip('Show password');
      expect(
        tester.getSemantics(toggle),
        isSemantics(
          tooltip: 'Show password',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      final size = tester.getSize(toggle);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));

      await tester.tap(toggle);
      await tester.pump();
      expect(
        tester.getSemantics(find.byTooltip('Hide password')),
        isSemantics(
          tooltip: 'Hide password',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('the toggle stays 48 dp with shrinkWrap tap targets', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          home: const Scaffold(body: PasswordField(label: 'Password')),
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byTooltip('Show password'));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('announces the error and marks the field invalid', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const PasswordField(label: 'Password', required: true),
      );
      key.currentState!.validate();
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Password',
          hint: 'This field is required',
          isTextField: true,
          isObscured: true,
          validationResult: SemanticsValidationResult.invalid,
        ),
      );
      handle.dispose();
    });
  });
}
