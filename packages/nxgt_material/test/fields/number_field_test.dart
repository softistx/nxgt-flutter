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
    NumberField field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  EditableText input(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText));

  String typed(WidgetTester tester) => input(tester).controller.text;

  testWidgets('opens the integer keypad by default', (tester) async {
    await pump(tester, const NumberField(label: 'Age', min: 0));

    expect(input(tester).keyboardType, TextInputType.number);
    expect(input(tester).textInputAction, TextInputAction.next);
  });

  testWidgets('opens the decimal and signed keypad when asked', (tester) async {
    await pump(tester, const NumberField(label: 'Delta', allowDecimal: true));

    expect(
      input(tester).keyboardType,
      const TextInputType.numberWithOptions(signed: true, decimal: true),
    );
  });

  testWidgets('refuses letters, decimals and signs it does not allow', (
    tester,
  ) async {
    await pump(tester, const NumberField(label: 'Age', min: 0));

    await tester.enterText(find.byType(EditableText), '12');
    await tester.enterText(find.byType(EditableText), '12a');
    expect(typed(tester), '12');
    await tester.enterText(find.byType(EditableText), '12.5');
    expect(typed(tester), '12');
    await tester.enterText(find.byType(EditableText), '-3');
    expect(typed(tester), '12');
  });

  testWidgets('accepts a point or a comma and a sign when allowed', (
    tester,
  ) async {
    await pump(tester, const NumberField(label: 'Delta', allowDecimal: true));

    await tester.enterText(find.byType(EditableText), '-1,5');
    expect(typed(tester), '-1,5');
    await tester.enterText(find.byType(EditableText), '-1.5');
    expect(typed(tester), '-1.5');
  });

  testWidgets('reports the parsed number', (tester) async {
    num? changed = -1;
    await pump(
      tester,
      NumberField(
        label: 'Price',
        allowDecimal: true,
        onChanged: (text) => changed = NumberField.parse(text),
      ),
    );

    await tester.enterText(find.byType(EditableText), '2,5');
    expect(changed, 2.5);
    await tester.enterText(find.byType(EditableText), '');
    expect(changed, isNull);
  });

  testWidgets('rejects values outside the range, in the user language', (
    tester,
  ) async {
    await pump(
      tester,
      const NumberField(label: 'Age', min: 18, max: 99, initialValue: '5'),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Enter a value of at least 18'), findsOneWidget);

    await pump(
      tester,
      const NumberField(label: 'Age', min: 18, max: 99, initialValue: '120'),
      locale: const Locale('fr'),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(find.text('Saisissez une valeur d’au plus 99'), findsOneWidget);
  });

  testWidgets('accepts a value in range, an empty optional one', (
    tester,
  ) async {
    await pump(
      tester,
      const NumberField(label: 'Age', min: 18, max: 99, initialValue: '30'),
    );
    expect(key.currentState!.validate(), isTrue);

    await pump(tester, const NumberField(label: 'Age'));
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('required rejects an empty value', (tester) async {
    await pump(tester, const NumberField(label: 'Age', required: true));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('runs the extra validator last', (tester) async {
    await pump(
      tester,
      NumberField(
        label: 'Age',
        initialValue: '3',
        validator: (_) => 'Even only',
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Even only'), findsOneWidget);
  });

  group('semantics', () {
    testWidgets('is a labelled text field', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const NumberField(label: 'Age'));

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Age',
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

    testWidgets('announces the range error and marks the field invalid', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const NumberField(label: 'Age', max: 9, initialValue: '10'),
      );
      key.currentState!.validate();
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Age',
          hint: 'Enter a value of at most 9',
          isTextField: true,
          validationResult: SemanticsValidationResult.invalid,
        ),
      );
      handle.dispose();
    });
  });
}
