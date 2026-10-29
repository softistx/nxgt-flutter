import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/dates.dart';

import '../support/host.dart';

void main() {
  late GlobalKey<FormState> key;
  setUp(() => key = GlobalKey<FormState>());

  Future<void> pump(
    WidgetTester tester,
    DateField field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  final may2026 = DateTime(2026, 5, 14);
  const label = 'Birth date';

  Future<void> pickDay(WidgetTester tester, String day) async {
    await tester.tap(find.text(day).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the label, then the formatted initial date', (
    tester,
  ) async {
    await pump(tester, DateField(label: label, initialValue: may2026));
    expect(find.text(label), findsOneWidget);
    expect(find.text('Thu, May 14'), findsOneWidget);
  });

  testWidgets('normalises the initial value to midnight', (tester) async {
    DateTime? saved;
    await pump(
      tester,
      DateField(
        label: label,
        initialValue: DateTime(2026, 5, 14, 15, 30),
        onSaved: (date) => saved = date,
      ),
    );
    key.currentState!.save();
    expect(saved, DateTime(2026, 5, 14));
  });

  testWidgets('opens the picker, picks a day and reports midnight', (
    tester,
  ) async {
    DateTime? changed;
    await pump(
      tester,
      DateField(
        label: label,
        initialValue: may2026,
        onChanged: (date) => changed = date,
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await pickDay(tester, '20');
    expect(changed, DateTime(2026, 5, 20));
    expect(find.text('Wed, May 20'), findsOneWidget);
  });

  testWidgets('cancel keeps the value', (tester) async {
    var calls = 0;
    await pump(
      tester,
      DateField(label: label, initialValue: may2026, onChanged: (_) => calls++),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Thu, May 14'), findsOneWidget);
  });

  testWidgets('the clear button empties the field and reports null', (
    tester,
  ) async {
    DateTime? changed = may2026;
    await pump(
      tester,
      DateField(
        label: label,
        initialValue: may2026,
        onChanged: (date) => changed = date,
      ),
    );
    await tester.tap(find.byTooltip('Clear $label'));
    await tester.pumpAndSettle();
    expect(changed, isNull);
    expect(find.text('Thu, May 14'), findsNothing);
    expect(find.byTooltip('Clear $label'), findsNothing);
  });

  testWidgets('clearable false and an empty field have no clear button', (
    tester,
  ) async {
    await pump(
      tester,
      DateField(label: label, initialValue: may2026, clearable: false),
    );
    expect(find.byTooltip('Clear $label'), findsNothing);
    await pump(tester, const DateField(label: label));
    expect(find.byTooltip('Clear $label'), findsNothing);
  });

  testWidgets('the clear button is a 48 dp target', (tester) async {
    await pump(tester, DateField(label: label, initialValue: may2026));
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('required reports an error until a date is picked', (
    tester,
  ) async {
    await pump(tester, const DateField(label: label, required: true));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('an optional empty field is valid; the validator runs', (
    tester,
  ) async {
    await pump(tester, const DateField(label: label));
    expect(key.currentState!.validate(), isTrue);
    await pump(
      tester,
      DateField(
        label: label,
        initialValue: may2026,
        validator: (date) => 'No thanks',
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('No thanks'), findsOneWidget);
  });

  testWidgets('a date out of range is an error with the bound', (tester) async {
    await pump(
      tester,
      DateField(
        label: label,
        initialValue: DateTime(2020, 1, 5),
        firstDate: DateTime(2024, 3),
        lastDate: DateTime(2026, 12, 31),
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.textContaining('on or after'), findsOneWidget);

    await pump(
      tester,
      DateField(
        label: label,
        initialValue: DateTime(2030, 1, 5),
        firstDate: DateTime(2024, 3),
        lastDate: DateTime(2026, 12, 31),
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.textContaining('on or before'), findsOneWidget);
  });

  testWidgets('reset returns to the initial value', (tester) async {
    await pump(tester, DateField(label: label, initialValue: may2026));
    await tester.tap(find.byTooltip('Clear $label'));
    await tester.pumpAndSettle();
    key.currentState!.reset();
    await tester.pump();
    expect(find.text('Thu, May 14'), findsOneWidget);
  });

  testWidgets('formats in French with the locale', (tester) async {
    await pump(
      tester,
      DateField(label: label, initialValue: may2026),
      locale: const Locale('fr'),
    );
    expect(find.text('jeu. 14 mai'), findsOneWidget);
    expect(find.byTooltip('Effacer $label'), findsOneWidget);
  });

  testWidgets('a formatter words the date', (tester) async {
    await pump(
      tester,
      DateField(
        label: label,
        initialValue: may2026,
        formatter: (date) => '${date.year}-${date.month}-${date.day}',
      ),
    );
    expect(find.text('2026-5-14'), findsOneWidget);
  });

  testWidgets('a disabled field does not open and is not validated', (
    tester,
  ) async {
    await pump(
      tester,
      const DateField(label: label, enabled: false, required: true),
    );
    await tester.tap(find.byType(InputDecorator), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('Enter on the focused field opens the picker', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pump(tester, DateField(label: label, focusNode: node));
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('Space on the focused field opens the picker', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pump(tester, DateField(label: label, focusNode: node));
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('the picker starts in range when the value is out of it', (
    tester,
  ) async {
    await pump(
      tester,
      DateField(
        label: label,
        firstDate: DateTime(2090),
        lastDate: DateTime(2095, 12, 31),
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('initialEntryMode input opens the typed entry', (tester) async {
    await pump(
      tester,
      const DateField(
        label: label,
        initialEntryMode: DatePickerEntryMode.input,
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('one merged node: button, label, value, hint', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      DateField(
        label: label,
        initialValue: may2026,
        helperText: 'As on your ID',
      ),
    );
    expect(
      tester.getSemantics(find.byType(InputDecorator)),
      matchesSemantics(
        label: label,
        value: 'Thu, May 14',
        hint: 'As on your ID',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('the error is the hint, announced once', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      const DateField(label: label, required: true, helperText: 'As on ID'),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(find.bySemanticsLabel('This field is required'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(InputDecorator)).hint,
      'This field is required',
    );
    handle.dispose();
  });

  testWidgets('lays out inside an IntrinsicHeight', (tester) async {
    await pump(tester, DateField(label: label, initialValue: may2026));
    await tester.pumpWidget(
      formHost([
        IntrinsicHeight(
          child: DateField(label: label, initialValue: may2026),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Thu, May 14'), findsOneWidget);
  });

  testWidgets('lays out at a large text scale without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: formHost([DateField(label: label, initialValue: may2026)]),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
