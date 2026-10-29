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
    TimeField field, {
    Locale locale = const Locale('en'),
    bool? alwaysUse24HourFormat,
  }) async {
    await tester.pumpWidget(const SizedBox());
    final host = formHost([field], formKey: key, locale: locale);
    await tester.pumpWidget(
      alwaysUse24HourFormat == null
          ? host
          : MediaQuery(
              data: MediaQueryData(
                alwaysUse24HourFormat: alwaysUse24HourFormat,
              ),
              child: host,
            ),
    );
    await tester.pumpAndSettle();
  }

  const afternoon = TimeOfDay(hour: 14, minute: 30);
  const label = 'Start time';

  testWidgets('shows the label, then the formatted initial time', (
    tester,
  ) async {
    await pump(tester, const TimeField(label: label, initialValue: afternoon));
    expect(find.text(label), findsOneWidget);
    expect(find.text('2:30 PM'), findsOneWidget);
  });

  testWidgets('opens the picker, confirms and reports the time', (
    tester,
  ) async {
    TimeOfDay? changed;
    await pump(
      tester,
      TimeField(
        label: label,
        initialValue: afternoon,
        onChanged: (time) => changed = time,
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(changed, afternoon);
  });

  testWidgets('picks a new time with the typed entry', (tester) async {
    TimeOfDay? changed;
    await pump(
      tester,
      TimeField(
        label: label,
        initialValue: afternoon,
        initialEntryMode: TimePickerEntryMode.input,
        onChanged: (time) => changed = time,
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '9');
    await tester.enterText(fields.last, '05');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(changed, const TimeOfDay(hour: 21, minute: 5));
    expect(find.text('9:05 PM'), findsOneWidget);
  });

  testWidgets('cancel keeps the value', (tester) async {
    var calls = 0;
    await pump(
      tester,
      TimeField(
        label: label,
        initialValue: afternoon,
        onChanged: (_) => calls++,
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('2:30 PM'), findsOneWidget);
  });

  testWidgets('the clear button empties the field and reports null', (
    tester,
  ) async {
    TimeOfDay? changed = afternoon;
    await pump(
      tester,
      TimeField(
        label: label,
        initialValue: afternoon,
        onChanged: (time) => changed = time,
      ),
    );
    await tester.tap(find.byTooltip('Clear $label'));
    await tester.pumpAndSettle();
    expect(changed, isNull);
    expect(find.text('2:30 PM'), findsNothing);
    expect(find.byTooltip('Clear $label'), findsNothing);
  });

  testWidgets('clearable false and an empty field have no clear button', (
    tester,
  ) async {
    await pump(
      tester,
      const TimeField(label: label, initialValue: afternoon, clearable: false),
    );
    expect(find.byTooltip('Clear $label'), findsNothing);
    await pump(tester, const TimeField(label: label));
    expect(find.byTooltip('Clear $label'), findsNothing);
  });

  testWidgets('the clear button is a 48 dp target', (tester) async {
    await pump(tester, const TimeField(label: label, initialValue: afternoon));
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('required reports an error until a time is picked', (
    tester,
  ) async {
    await pump(tester, const TimeField(label: label, required: true));
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('an optional empty field is valid; the validator runs', (
    tester,
  ) async {
    await pump(tester, const TimeField(label: label));
    expect(key.currentState!.validate(), isTrue);
    await pump(
      tester,
      TimeField(
        label: label,
        initialValue: afternoon,
        validator: (time) => 'No thanks',
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('No thanks'), findsOneWidget);
  });

  testWidgets('an empty optional field does not call the validator', (
    tester,
  ) async {
    var calls = 0;
    await pump(
      tester,
      TimeField(
        label: label,
        validator: (time) {
          calls++;
          return 'bad';
        },
      ),
    );
    expect(key.currentState!.validate(), isTrue);
    expect(calls, 0);
  });

  testWidgets('save reports the time and reset returns to it', (tester) async {
    TimeOfDay? saved;
    await pump(
      tester,
      TimeField(
        label: label,
        initialValue: afternoon,
        onSaved: (time) => saved = time,
      ),
    );
    key.currentState!.save();
    expect(saved, afternoon);
    await tester.tap(find.byTooltip('Clear $label'));
    await tester.pumpAndSettle();
    key.currentState!.reset();
    await tester.pump();
    expect(find.text('2:30 PM'), findsOneWidget);
  });

  testWidgets('12 hour clock by default, 24 hour when the platform says so', (
    tester,
  ) async {
    await pump(tester, const TimeField(label: label, initialValue: afternoon));
    expect(find.text('2:30 PM'), findsOneWidget);
    await pump(
      tester,
      const TimeField(label: label, initialValue: afternoon),
      alwaysUse24HourFormat: true,
    );
    expect(find.text('14:30'), findsOneWidget);
  });

  testWidgets('use24HourFormat overrides the platform in both directions', (
    tester,
  ) async {
    await pump(
      tester,
      const TimeField(
        label: label,
        initialValue: afternoon,
        use24HourFormat: true,
      ),
    );
    expect(find.text('14:30'), findsOneWidget);
    await pump(
      tester,
      const TimeField(
        label: label,
        initialValue: afternoon,
        use24HourFormat: false,
      ),
      alwaysUse24HourFormat: true,
    );
    expect(find.text('2:30 PM'), findsOneWidget);
  });

  testWidgets('use24HourFormat drives the picker: no AM/PM toggle', (
    tester,
  ) async {
    await pump(
      tester,
      const TimeField(
        label: label,
        initialValue: afternoon,
        use24HourFormat: true,
      ),
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await pump(
      tester,
      const TimeField(
        label: label,
        initialValue: afternoon,
        use24HourFormat: false,
      ),
      alwaysUse24HourFormat: true,
    );
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.text('AM'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
  });

  testWidgets('formats in French with the locale', (tester) async {
    await pump(
      tester,
      const TimeField(label: label, initialValue: afternoon),
      locale: const Locale('fr'),
    );
    expect(find.text('14:30'), findsOneWidget);
    expect(find.byTooltip('Effacer $label'), findsOneWidget);
  });

  testWidgets('a formatter words the time', (tester) async {
    await pump(
      tester,
      TimeField(
        label: label,
        initialValue: afternoon,
        formatter: (time) => '${time.hour}h${time.minute}',
      ),
    );
    expect(find.text('14h30'), findsOneWidget);
  });

  testWidgets('a disabled field does not open and is not validated', (
    tester,
  ) async {
    await pump(
      tester,
      const TimeField(label: label, enabled: false, required: true),
    );
    await tester.tap(find.byType(InputDecorator), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsNothing);
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('Enter on the focused field opens the picker', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pump(tester, TimeField(label: label, focusNode: node));
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  testWidgets('Space on the focused field opens the picker', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pump(tester, TimeField(label: label, focusNode: node));
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  testWidgets('one merged node: button, label, value, hint', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      const TimeField(
        label: label,
        initialValue: afternoon,
        helperText: 'Local time',
      ),
    );
    expect(
      tester.getSemantics(find.byType(InputDecorator)),
      matchesSemantics(
        label: label,
        value: '2:30 PM',
        hint: 'Local time',
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
      const TimeField(label: label, required: true, helperText: 'Local time'),
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
    handle.dispose();
  });

  testWidgets('lays out inside an IntrinsicHeight', (tester) async {
    await pump(tester, const TimeField(label: label, initialValue: afternoon));
    await tester.pumpWidget(
      formHost([
        const IntrinsicHeight(
          child: TimeField(label: label, initialValue: afternoon),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('2:30 PM'), findsOneWidget);
  });

  testWidgets('lays out at a large text scale without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: formHost([
          const TimeField(label: label, initialValue: afternoon),
        ]),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
