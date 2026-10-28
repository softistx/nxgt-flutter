import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/fields.dart';

import '../support/host.dart';

void main() {
  late GlobalKey<FormState> key;
  setUp(() => key = GlobalKey<FormState>());

  Future<void> pump(WidgetTester tester, TextAreaField field) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key));
    await tester.pumpAndSettle();
  }

  EditableText input(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText));

  testWidgets('is multi-line with a newline action', (tester) async {
    await pump(tester, const TextAreaField(label: 'Notes'));

    expect(input(tester).keyboardType, TextInputType.multiline);
    expect(input(tester).textInputAction, TextInputAction.newline);
    expect(input(tester).minLines, 3);
    expect(input(tester).maxLines, 8);
    expect(input(tester).textCapitalization, TextCapitalization.sentences);
  });

  testWidgets('honours minLines and maxLines', (tester) async {
    await pump(
      tester,
      const TextAreaField(label: 'Notes', minLines: 2, maxLines: 4),
    );

    expect(input(tester).minLines, 2);
    expect(input(tester).maxLines, 4);
  });

  testWidgets('shows a counter and stops at maxLength', (tester) async {
    await pump(tester, const TextAreaField(label: 'Notes', maxLength: 5));
    expect(find.text('0/5'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'abcdefgh');
    await tester.pump();

    expect(input(tester).controller.text, 'abcde');
    expect(find.text('5/5'), findsOneWidget);
  });

  testWidgets('required rejects a blank value', (tester) async {
    await pump(
      tester,
      const TextAreaField(label: 'Notes', required: true, initialValue: '  '),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('accepts any text when optional', (tester) async {
    await pump(tester, const TextAreaField(label: 'Notes'));
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('runs the extra validator', (tester) async {
    await pump(
      tester,
      TextAreaField(label: 'Notes', validator: (_) => 'Too rude'),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Too rude'), findsOneWidget);
  });

  group('semantics', () {
    testWidgets('is a labelled multi-line text field', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const TextAreaField(label: 'Notes'));

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Notes',
          isTextField: true,
          isMultiline: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('announces the error and marks the field invalid', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const TextAreaField(label: 'Notes', required: true));
      key.currentState!.validate();
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(TextFormField)),
        isSemantics(
          label: 'Notes',
          hint: 'This field is required',
          isTextField: true,
          validationResult: SemanticsValidationResult.invalid,
        ),
      );
      handle.dispose();
    });
  });
}
