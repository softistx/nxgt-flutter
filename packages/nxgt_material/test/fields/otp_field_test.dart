import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/fields.dart';

import '../support/host.dart';

void main() {
  late GlobalKey<FormState> key;
  setUp(() => key = GlobalKey<FormState>());

  Future<void> pump(
    WidgetTester tester,
    OtpField field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  EditableText input(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText));

  Finder slot(int i) => find.byKey(ValueKey('otp-slot-$i'));

  testWidgets('draws 48 dp slots over one input with the one-time hint', (
    tester,
  ) async {
    await pump(tester, const OtpField(label: 'Code'));

    expect(find.byType(EditableText), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      expect(tester.getSize(slot(i)), const Size.square(48));
    }
    expect(slot(6), findsNothing);
    expect(input(tester).autofillHints, const [AutofillHints.oneTimeCode]);
    expect(input(tester).keyboardType, TextInputType.number);
    expect(tester.getSize(find.byType(TextFormField)).height, closeTo(48, 2));
  });

  testWidgets('typing fills the slots and reports changes', (tester) async {
    final changes = <String>[];
    await pump(tester, OtpField(label: 'Code', onChanged: changes.add));

    await tester.enterText(find.byType(EditableText), '123');
    await tester.pump();

    expect(changes, ['123']);
    expect(find.descendant(of: slot(0), matching: find.text('1')), findsOne);
    expect(find.descendant(of: slot(2), matching: find.text('3')), findsOne);
    expect(
      find.descendant(of: slot(3), matching: find.byType(Text)),
      findsNothing,
    );
  });

  testWidgets('a paste is stripped of non-digits and cut at length', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pump(tester, OtpField(label: 'Code', controller: controller));

    await tester.enterText(find.byType(EditableText), '12-34 56 78');
    await tester.pump();
    expect(controller.text, '123456');

    await tester.enterText(find.byType(EditableText), 'ab');
    expect(controller.text, '');
  });

  testWidgets('a custom length draws that many slots', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pump(
      tester,
      OtpField(label: 'Code', length: 4, controller: controller),
    );

    await tester.enterText(find.byType(EditableText), '987654');
    expect(controller.text, '9876');
    expect(slot(3), findsOneWidget);
    expect(slot(4), findsNothing);
  });

  testWidgets('onCompleted fires once per completion and never submits', (
    tester,
  ) async {
    final done = <String>[];
    var saved = 0;
    await pump(
      tester,
      OtpField(label: 'Code', onCompleted: done.add, onSaved: (_) => saved++),
    );

    await tester.enterText(find.byType(EditableText), '12345');
    expect(done, isEmpty);
    await tester.enterText(find.byType(EditableText), '123456');
    await tester.enterText(find.byType(EditableText), '123456789');
    expect(done, ['123456']);
    await tester.enterText(find.byType(EditableText), '1234');
    await tester.enterText(find.byType(EditableText), '654321');
    expect(done, ['123456', '654321']);
    expect(saved, 0);
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('a code already complete does not fire onCompleted', (
    tester,
  ) async {
    final controller = TextEditingController(text: '123456');
    addTearDown(controller.dispose);
    var fired = 0;
    await pump(
      tester,
      OtpField(
        label: 'Code',
        controller: controller,
        onCompleted: (_) => fired++,
      ),
    );

    expect(fired, 0);
  });

  testWidgets('inside a Form: incomplete, required and extra validator', (
    tester,
  ) async {
    await pump(
      tester,
      OtpField(
        label: 'Code',
        required: true,
        validator: (v) => v == '111111' ? 'No ones' : null,
      ),
    );

    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '12');
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Enter all 6 digits'), findsOneWidget);
    await tester.pump();
    expect(tester.widget<Container>(slot(0)).decoration, isNotNull);

    await tester.enterText(find.byType(EditableText), '111111');
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('No ones'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '123456');
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('an optional empty code is valid; onSaved gets the digits', (
    tester,
  ) async {
    String? saved;
    await pump(tester, OtpField(label: 'Code', onSaved: (v) => saved = v));

    expect(key.currentState!.validate(), isTrue);
    await tester.enterText(find.byType(EditableText), '4242');
    key.currentState!.save();
    expect(saved, '4242');
  });

  testWidgets('the incomplete message is localized', (tester) async {
    await pump(
      tester,
      const OtpField(label: 'Code', length: 4),
      locale: const Locale('fr'),
    );
    await tester.enterText(find.byType(EditableText), '1');
    key.currentState!.validate();
    await tester.pump();

    expect(find.text('Saisissez les 4 chiffres'), findsOneWidget);
  });

  testWidgets('shows the helper text', (tester) async {
    await pump(
      tester,
      const OtpField(label: 'Code', helperText: 'Sent by SMS'),
    );

    expect(find.text('Sent by SMS'), findsOneWidget);
  });

  testWidgets('a disabled field takes no input', (tester) async {
    await pump(tester, const OtpField(label: 'Code', enabled: false));

    expect(input(tester).focusNode.canRequestFocus, isFalse);
  });

  testWidgets('autofocus focuses the input', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pump(
      tester,
      OtpField(label: 'Code', focusNode: node, autofocus: true),
    );

    expect(node.hasFocus, isTrue);
  });

  testWidgets('semantics: a single labelled text field, slots hidden', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const OtpField(label: 'Code'));
    await tester.enterText(find.byType(EditableText), '12');
    await tester.pump();

    final node = tester.getSemantics(find.byType(EditableText));
    expect(node.label, contains('Code'));
    expect(node.flagsCollection.isTextField, isTrue);
    expect(find.bySemanticsLabel('1'), findsNothing);
    handle.dispose();
  });

  testWidgets('keeps slots left to right in a right-to-left app', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedHost(const OtpField(label: 'Code'), direction: TextDirection.rtl),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(slot(0)).dx,
      lessThan(tester.getTopLeft(slot(5)).dx),
    );
  });

  testWidgets('works inside an IntrinsicHeight', (tester) async {
    await tester.pumpWidget(
      themedHost(const IntrinsicHeight(child: OtpField(label: 'Code'))),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(OtpField), findsOneWidget);
  });

  testWidgets('scales down on a screen narrower than its slots', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pump(tester, const OtpField(label: 'Code'));

    expect(tester.takeException(), isNull);
    expect(tester.getRect(slot(0)).width, lessThan(48));
  });
}
