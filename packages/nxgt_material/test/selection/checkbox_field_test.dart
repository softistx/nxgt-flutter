import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/selection.dart';

import '../support/host.dart';

void main() {
  late GlobalKey<FormState> key;
  setUp(() => key = GlobalKey<FormState>());

  Future<void> pump(
    WidgetTester tester,
    CheckboxField field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  bool checked(WidgetTester tester) =>
      tester.widget<Checkbox>(find.byType(Checkbox)).value ?? false;

  testWidgets('exposes label and checked state to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const CheckboxField(label: 'Accept the terms'));
    expect(
      tester.getSemantics(find.byType(Checkbox)),
      matchesSemantics(
        label: 'Accept the terms',
        hasCheckedState: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    await pump(
      tester,
      const CheckboxField(label: 'Accept the terms', initialValue: true),
    );
    expect(
      tester.getSemantics(find.byType(Checkbox)),
      matchesSemantics(
        label: 'Accept the terms',
        hasCheckedState: true,
        isChecked: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('a tap on the label toggles and reports the change', (
    tester,
  ) async {
    final changes = <bool?>[];
    await pump(tester, CheckboxField(label: 'Accept', onChanged: changes.add));

    await tester.tap(find.text('Accept'));
    await tester.pump();
    expect(checked(tester), isTrue);
    await tester.tap(find.text('Accept'));
    await tester.pump();
    expect(checked(tester), isFalse);
    expect(changes, [true, false]);
  });

  testWidgets('required shows a localized error on validate, then clears', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const CheckboxField(label: 'Accept', required: true));
    expect(find.text('This field is required'), findsNothing);

    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('This field is required')).label,
      contains('This field is required'),
    );
    // Announced: an alert role, and a live region where the role is silent.
    final alert = find.ancestor(
      of: find.text('This field is required'),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.role == SemanticsRole.alert,
      ),
    );
    expect(alert, findsOneWidget);
    expect(
      tester
          .getSemantics(find.text('This field is required'))
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isTrue,
    );

    await tester.tap(find.text('Accept'));
    await tester.pump();
    expect(key.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('This field is required'), findsNothing);
    handle.dispose();
  });

  testWidgets('an optional box is valid unchecked; the validator runs', (
    tester,
  ) async {
    await pump(tester, const CheckboxField(label: 'Accept'));
    expect(key.currentState!.validate(), isTrue);

    await pump(
      tester,
      CheckboxField(
        label: 'Accept',
        validator: (value) => value == true ? 'Not that one' : null,
      ),
    );
    await tester.tap(find.text('Accept'));
    await tester.pump();
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Not that one'), findsOneWidget);
  });

  testWidgets('autovalidateMode always shows the error at once', (
    tester,
  ) async {
    await pump(
      tester,
      const CheckboxField(
        label: 'Accept',
        required: true,
        autovalidateMode: AutovalidateMode.always,
      ),
    );
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('shows the helper text, replaced by the error', (tester) async {
    await pump(
      tester,
      const CheckboxField(
        label: 'Accept',
        required: true,
        helperText: 'You can change this later',
      ),
    );
    expect(find.text('You can change this later'), findsOneWidget);
    key.currentState!.validate();
    await tester.pump();
    expect(find.text('You can change this later'), findsNothing);
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('Form save passes the value; reset restores the initial one', (
    tester,
  ) async {
    bool? saved;
    await pump(
      tester,
      CheckboxField(label: 'Accept', onSaved: (v) => saved = v),
    );
    await tester.tap(find.text('Accept'));
    await tester.pump();
    key.currentState!.save();
    expect(saved, isTrue);

    key.currentState!.reset();
    await tester.pump();
    expect(checked(tester), isFalse);
  });

  testWidgets('disabled ignores taps and skips validation', (tester) async {
    final handle = tester.ensureSemantics();
    final changes = <bool?>[];
    await pump(
      tester,
      CheckboxField(
        label: 'Accept',
        required: true,
        enabled: false,
        onChanged: changes.add,
      ),
    );
    await tester.tap(find.text('Accept'), warnIfMissed: false);
    await tester.pump();
    expect(checked(tester), isFalse);
    expect(changes, isEmpty);
    expect(key.currentState!.validate(), isTrue);
    expect(
      tester.getSemantics(find.byType(Checkbox)),
      matchesSemantics(
        label: 'Accept',
        hasCheckedState: true,
        hasSelectedState: true,
        hasEnabledState: true,
      ),
    );
    handle.dispose();
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
    testWidgets('is at least 48 dp high and full width on $platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await pump(tester, const CheckboxField(label: 'Accept'));
        final size = tester.getSize(find.byType(CheckboxListTile));
        expect(size.height, greaterThanOrEqualTo(48));
        expect(size.width, tester.getSize(find.byType(Form)).width);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('works in right-to-left', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      themedHost(
        Form(
          key: key,
          child: const CheckboxField(label: 'Accept', required: true),
        ),
        direction: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();
    key.currentState!.validate();
    await tester.pump();
    expect(tester.takeException(), isNull);
    final box = tester.getRect(find.byType(Checkbox));
    final label = tester.getRect(find.text('Accept'));
    expect(box.center.dx, greaterThan(label.center.dx));
  });

  testWidgets('a long label wraps at text scale 2 without overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pump(
      tester,
      CheckboxField(
        label:
            'I have read and I accept the terms of service and the privacy '
                'policy of this application' *
            2,
        required: true,
        helperText: 'Required to continue',
      ),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(CheckboxListTile)).height,
      greaterThan(150),
    );
  });

  testWidgets('is safe inside an IntrinsicHeight', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      formHost([
        const IntrinsicHeight(
          child: CheckboxField(label: 'Accept', helperText: 'Help'),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('speaks French', (tester) async {
    await pump(
      tester,
      const CheckboxField(label: 'Accepter', required: true),
      locale: const Locale('fr'),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(find.text('Ce champ est obligatoire'), findsOneWidget);
  });
}
