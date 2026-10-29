import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/selection.dart';

import '../support/host.dart';

const List<ChoiceOption<String>> _options = [
  ChoiceOption(value: 'a', label: 'Alpha', description: 'First'),
  ChoiceOption(value: 'b', label: 'Beta'),
  ChoiceOption(value: 'c', label: 'Gamma'),
];

void main() {
  late GlobalKey<FormState> key;
  setUp(() => key = GlobalKey<FormState>());

  Future<void> pump(
    WidgetTester tester,
    RadioGroupField<String> field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  RadioGroupField<String> field({
    String? initialValue,
    ValueChanged<String?>? onChanged,
    bool required = false,
    bool enabled = true,
    List<ChoiceOption<String>> options = _options,
    String? helperText,
    FormFieldSetter<String?>? onSaved,
    AutovalidateMode? autovalidateMode,
  }) => RadioGroupField<String>(
    label: 'Letter',
    options: options,
    initialValue: initialValue,
    onChanged: onChanged,
    required: required,
    enabled: enabled,
    helperText: helperText,
    onSaved: onSaved,
    autovalidateMode: autovalidateMode,
  );

  testWidgets('the group has a labelled container, each option its state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, field(initialValue: 'b'));
    expect(find.text('Letter'), findsOneWidget);
    expect(find.bySemanticsLabel('Letter'), findsOneWidget);
    final group = tester.getSemantics(find.bySemanticsLabel('Letter'));
    expect(group.getSemanticsData().label, 'Letter');

    final alpha = tester.getSemantics(find.text('Alpha')).getSemanticsData();
    expect(alpha.label, contains('Alpha'));
    expect(alpha.flagsCollection.isChecked, CheckedState.isFalse);
    final beta = tester.getSemantics(find.text('Beta')).getSemanticsData();
    expect(beta.flagsCollection.isChecked, CheckedState.isTrue);
    expect(beta.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    handle.dispose();
  });

  testWidgets('a tap chooses an option and reports it', (tester) async {
    final changes = <String?>[];
    await pump(tester, field(onChanged: changes.add));
    await tester.tap(find.text('Beta'));
    await tester.pump();
    await tester.tap(find.text('Gamma'));
    await tester.pump();
    expect(changes, ['b', 'c']);
    final group = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );
    expect(group.groupValue, 'c');
  });

  testWidgets('arrow keys move the choice in the group', (tester) async {
    final changes = <String?>[];
    await pump(tester, field(initialValue: 'a', onChanged: changes.add));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(changes, ['b']);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(changes, ['b', 'c', 'b']);
  });

  testWidgets('required shows an announced error on validate, tied as hint', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, field(required: true, helperText: 'Help'));
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Letter'))
          .getSemanticsData()
          .hint,
      'Help',
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
    expect(find.text('Help'), findsNothing);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Letter'))
          .getSemanticsData()
          .hint,
      'This field is required',
    );
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
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(key.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('This field is required'), findsNothing);
    handle.dispose();
  });

  testWidgets('the validator runs after the required check', (tester) async {
    await pump(
      tester,
      RadioGroupField<String>(
        label: 'Letter',
        options: _options,
        validator: (v) => v == 'a' ? 'Not that one' : null,
      ),
    );
    expect(key.currentState!.validate(), isTrue);
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Not that one'), findsOneWidget);
  });

  testWidgets('Form save passes the value; reset restores the initial one', (
    tester,
  ) async {
    String? saved;
    await pump(tester, field(initialValue: 'a', onSaved: (v) => saved = v));
    await tester.tap(find.text('Gamma'));
    await tester.pump();
    key.currentState!.save();
    expect(saved, 'c');
    key.currentState!.reset();
    await tester.pump();
    expect(
      tester
          .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
          .groupValue,
      'a',
    );
  });

  testWidgets('a disabled field ignores taps, skips validation, no error', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final changes = <String?>[];
    await pump(
      tester,
      field(
        required: true,
        enabled: false,
        onChanged: changes.add,
        autovalidateMode: AutovalidateMode.always,
      ),
    );
    await tester.tap(find.text('Beta'), warnIfMissed: false);
    await tester.pump();
    expect(changes, isEmpty);
    expect(key.currentState!.validate(), isTrue);
    expect(find.text('This field is required'), findsNothing);
    final beta = tester.getSemantics(find.text('Beta')).getSemanticsData();
    expect(beta.flagsCollection.isEnabled, Tristate.isFalse);
    handle.dispose();
  });

  testWidgets('a disabled option is not chosen and skipped by arrow keys', (
    tester,
  ) async {
    final changes = <String?>[];
    await pump(
      tester,
      field(
        initialValue: 'a',
        onChanged: changes.add,
        options: const [
          ChoiceOption(value: 'a', label: 'Alpha'),
          ChoiceOption(value: 'b', label: 'Beta', enabled: false),
          ChoiceOption(value: 'c', label: 'Gamma'),
        ],
      ),
    );
    await tester.tap(find.text('Beta'), warnIfMissed: false);
    await tester.pump();
    expect(changes, isEmpty);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(changes, ['c']);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
    testWidgets('each option is 48 dp high and full width on $platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await pump(tester, field());
        for (final tile in tester.widgetList(
          find.byType(RadioListTile<String>),
        )) {
          final size = tester.getSize(find.byWidget(tile));
          expect(size.height, greaterThanOrEqualTo(48));
          expect(size.width, tester.getSize(find.byType(Form)).width);
        }
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('works in right-to-left', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      themedHost(
        Form(key: key, child: field(required: true)),
        direction: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();
    key.currentState!.validate();
    await tester.pump();
    expect(tester.takeException(), isNull);
    final radio = tester.getRect(find.byType(Radio<String>).first);
    final label = tester.getRect(find.text('Alpha'));
    expect(radio.center.dx, greaterThan(label.center.dx));
  });

  testWidgets('long labels wrap at text scale 2 without overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pump(
      tester,
      field(
        required: true,
        helperText: 'Required to continue',
        options: [
          ChoiceOption(
            value: 'a',
            label: 'A rather long option label that wraps on a phone' * 2,
            description: 'And a rather long description as well' * 2,
          ),
          _options[1],
        ],
      ),
    );
    key.currentState!.validate();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(RadioListTile<String>).first).height,
      greaterThan(150),
    );
  });

  testWidgets('is safe inside an IntrinsicHeight', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      formHost([IntrinsicHeight(child: field(helperText: 'Help'))]),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('works inside a coloured ancestor', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      themedHost(ColoredBox(color: Colors.amber, child: field())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('speaks French', (tester) async {
    await pump(tester, field(required: true), locale: const Locale('fr'));
    key.currentState!.validate();
    await tester.pump();
    expect(find.text('Ce champ est obligatoire'), findsOneWidget);
  });

  testWidgets('asserts on duplicate values and a foreign initial value', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      formHost([
        field(
          options: const [
            ChoiceOption(value: 'a', label: 'One'),
            ChoiceOption(value: 'a', label: 'Two'),
          ],
        ),
      ]),
    );
    await tester.pump();
    expect(tester.takeException(), isA<AssertionError>());
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field(initialValue: 'z')]));
    await tester.pump();
    expect(tester.takeException(), isA<AssertionError>());
  });

  testWidgets('focusNode goes to the first enabled option, if any', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    Future<void> show(List<bool> enabled, {bool fieldEnabled = true}) => pump(
      tester,
      RadioGroupField<String>(
        label: 'L',
        focusNode: node,
        enabled: fieldEnabled,
        options: [
          for (final (i, e) in enabled.indexed)
            ChoiceOption(value: 'v$i', label: 'Option $i', enabled: e),
        ],
      ),
    );

    await show([false, true, true]);
    expect(node.context, isNotNull);
    expect(
      tester
          .getRect(find.byType(RadioListTile<String>).at(1))
          .contains(node.rect.center),
      isTrue,
    );

    await show([false, false]);
    expect(node.context?.mounted ?? false, isFalse);
    await show([true, true], fieldEnabled: false);
    expect(node.context?.mounted ?? false, isFalse);
    await show([true, true]);
    expect(
      tester
          .getRect(find.byType(RadioListTile<String>).first)
          .contains(node.rect.center),
      isTrue,
    );
  });
}
