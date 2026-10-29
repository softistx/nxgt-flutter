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
    DateRangeField field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  final may2026 = DateTimeRange(
    start: DateTime(2026, 5, 14),
    end: DateTime(2026, 5, 16),
  );
  const label = 'Stay';
  const may2026Text = 'Thu, May 14 to Sat, May 16';

  testWidgets('shows the label, then the spoken initial range', (tester) async {
    await pump(tester, DateRangeField(label: label, initialValue: may2026));
    expect(find.text(label), findsOneWidget);
    expect(find.text(may2026Text), findsOneWidget);
  });

  testWidgets('normalises the initial range to midnight', (tester) async {
    DateTimeRange? saved;
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: DateTimeRange(
          start: DateTime(2026, 5, 14, 15, 30),
          end: DateTime(2026, 5, 16, 9),
        ),
        onSaved: (range) => saved = range,
      ),
    );
    key.currentState!.save();
    expect(saved, may2026);
  });

  testWidgets('opens the picker, picks a range and reports midnights', (
    tester,
  ) async {
    DateTimeRange? changed;
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: may2026,
        onChanged: (range) => changed = range,
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePickerDialog), findsOneWidget);
    await tester.tap(find.text('20').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('22').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      changed,
      DateTimeRange(start: DateTime(2026, 5, 20), end: DateTime(2026, 5, 22)),
    );
    expect(find.text('Wed, May 20 to Fri, May 22'), findsOneWidget);
  });

  testWidgets('closing the picker keeps the value', (tester) async {
    var calls = 0;
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: may2026,
        onChanged: (_) => calls++,
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text(may2026Text), findsOneWidget);
  });

  testWidgets('the clear button empties the field and reports null', (
    tester,
  ) async {
    DateTimeRange? changed = may2026;
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: may2026,
        onChanged: (range) => changed = range,
      ),
    );
    await tester.tap(find.byTooltip('Clear $label'));
    await tester.pumpAndSettle();
    expect(changed, isNull);
    expect(find.text(may2026Text), findsNothing);
    expect(find.byTooltip('Clear $label'), findsNothing);
  });

  testWidgets('clearable false and an empty field have no clear button', (
    tester,
  ) async {
    await pump(
      tester,
      DateRangeField(label: label, initialValue: may2026, clearable: false),
    );
    expect(find.byTooltip('Clear $label'), findsNothing);
    await pump(tester, const DateRangeField(label: label));
    expect(find.byTooltip('Clear $label'), findsNothing);
  });

  testWidgets('the clear button is a 48 dp target', (tester) async {
    await pump(tester, DateRangeField(label: label, initialValue: may2026));
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('required reports an error until a range is picked', (
    tester,
  ) async {
    await pump(tester, const DateRangeField(label: label, required: true));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('an optional empty field is valid; the validator runs', (
    tester,
  ) async {
    await pump(tester, const DateRangeField(label: label));
    expect(key.currentState!.validate(), isTrue);
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: may2026,
        validator: (range) => 'No thanks',
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('No thanks'), findsOneWidget);
  });

  testWidgets('a start before firstDate or an end after lastDate is an error', (
    tester,
  ) async {
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: DateTimeRange(
          start: DateTime(2020, 1, 5),
          end: DateTime(2025),
        ),
        firstDate: DateTime(2024, 3),
        lastDate: DateTime(2026, 12, 31),
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.textContaining('on or after'), findsOneWidget);

    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: DateTimeRange(
          start: DateTime(2026, 12),
          end: DateTime(2027, 1, 5),
        ),
        firstDate: DateTime(2024, 3),
        lastDate: DateTime(2026, 12, 31),
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.textContaining('on or before'), findsOneWidget);
  });

  testWidgets('a range inside the bounds is valid', (tester) async {
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: may2026,
        firstDate: DateTime(2026, 5, 14),
        lastDate: DateTime(2026, 5, 16),
      ),
    );
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('reset returns to the initial value', (tester) async {
    await pump(tester, DateRangeField(label: label, initialValue: may2026));
    await tester.tap(find.byTooltip('Clear $label'));
    await tester.pumpAndSettle();
    key.currentState!.reset();
    await tester.pump();
    expect(find.text(may2026Text), findsOneWidget);
  });

  testWidgets('speaks the range in French with the locale', (tester) async {
    await pump(
      tester,
      DateRangeField(label: label, initialValue: may2026),
      locale: const Locale('fr'),
    );
    expect(find.text('du jeu. 14 mai au sam. 16 mai'), findsOneWidget);
    expect(find.byTooltip('Effacer $label'), findsOneWidget);
  });

  testWidgets('a formatter words the range', (tester) async {
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: may2026,
        formatter: (range) => '${range.duration.inDays + 1} nights',
      ),
    );
    expect(find.text('3 nights'), findsOneWidget);
  });

  testWidgets('a disabled field does not open and is not validated', (
    tester,
  ) async {
    await pump(
      tester,
      const DateRangeField(label: label, enabled: false, required: true),
    );
    await tester.tap(find.byType(InputDecorator), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePickerDialog), findsNothing);
    expect(key.currentState!.validate(), isTrue);
  });

  for (final (name, logical) in [
    ('Enter', LogicalKeyboardKey.enter),
    ('Space', LogicalKeyboardKey.space),
  ]) {
    testWidgets('$name on the focused field opens the picker', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pump(tester, DateRangeField(label: label, focusNode: node));
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(logical);
      await tester.pumpAndSettle();
      expect(find.byType(DateRangePickerDialog), findsOneWidget);
    });
  }

  testWidgets('the picker opens when the value is out of the bounds', (
    tester,
  ) async {
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: may2026,
        firstDate: DateTime(2090),
        lastDate: DateTime(2095, 12, 31),
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    final dialog = tester.widget<DateRangePickerDialog>(
      find.byType(DateRangePickerDialog),
    );
    expect(
      dialog.initialDateRange,
      DateTimeRange(start: DateTime(2090), end: DateTime(2090)),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the picker opens with no range when there is no value', (
    tester,
  ) async {
    await pump(tester, const DateRangeField(label: label));
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    final dialog = tester.widget<DateRangePickerDialog>(
      find.byType(DateRangePickerDialog),
    );
    expect(dialog.initialDateRange, isNull);
  });

  testWidgets('initialEntryMode input opens the typed entry', (tester) async {
    await pump(
      tester,
      const DateRangeField(
        label: label,
        initialEntryMode: DatePickerEntryMode.input,
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('one merged node: button, label, spoken range, hint', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      DateRangeField(
        label: label,
        initialValue: may2026,
        helperText: 'Check-in to check-out',
      ),
    );
    expect(
      tester.getSemantics(find.byType(InputDecorator)),
      matchesSemantics(
        label: label,
        value: may2026Text,
        hint: 'Check-in to check-out',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('the error is the hint; the footer is the only live region', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      const DateRangeField(label: label, required: true, helperText: 'Dates'),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(
      tester.getSemantics(find.byType(InputDecorator)).hint,
      'This field is required',
    );
    final live = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.liveRegion == true,
    );
    expect(live, findsOneWidget);
    expect(
      find.descendant(of: live, matching: find.text('This field is required')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('an empty optional field does not call the validator', (
    tester,
  ) async {
    var calls = 0;
    await pump(
      tester,
      DateRangeField(
        label: label,
        validator: (range) {
          calls++;
          return 'bad';
        },
      ),
    );
    expect(key.currentState!.validate(), isTrue);
    expect(calls, 0);
  });

  testWidgets('lays out inside an IntrinsicHeight', (tester) async {
    await pump(tester, DateRangeField(label: label, initialValue: may2026));
    await tester.pumpWidget(
      formHost([
        IntrinsicHeight(
          child: DateRangeField(label: label, initialValue: may2026),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(may2026Text), findsOneWidget);
  });

  testWidgets('lays out at a large text scale without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: formHost([DateRangeField(label: label, initialValue: may2026)]),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
