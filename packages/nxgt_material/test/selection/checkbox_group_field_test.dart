import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
    CheckboxGroupField<String> field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  CheckboxGroupField<String> field({
    Set<String> initialValue = const {},
    ValueChanged<Set<String>>? onChanged,
    bool required = false,
    bool enabled = true,
    List<ChoiceOption<String>> options = _options,
    String? helperText,
    FormFieldSetter<Set<String>>? onSaved,
    AutovalidateMode? autovalidateMode,
  }) => CheckboxGroupField<String>(
    label: 'Letters',
    options: options,
    initialValue: initialValue,
    onChanged: onChanged,
    required: required,
    enabled: enabled,
    helperText: helperText,
    onSaved: onSaved,
    autovalidateMode: autovalidateMode,
  );

  Set<String> checked(WidgetTester tester) => {
    for (final tile in tester.widgetList<CheckboxListTile>(
      find.byType(CheckboxListTile),
    ))
      if (tile.value ?? false) (tile.title! as Text).data!,
  };

  testWidgets('the group has a labelled container, each option its state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, field(initialValue: {'b'}));
    expect(find.text('Letters'), findsOneWidget);
    expect(find.bySemanticsLabel('Letters'), findsOneWidget);
    final alpha = tester.getSemantics(find.text('Alpha')).getSemanticsData();
    expect(alpha.label, contains('Alpha'));
    expect(alpha.flagsCollection.isChecked, CheckedState.isFalse);
    final beta = tester.getSemantics(find.text('Beta')).getSemanticsData();
    expect(beta.flagsCollection.isChecked, CheckedState.isTrue);
    handle.dispose();
  });

  testWidgets('taps report new unmodifiable sets and never mutate', (
    tester,
  ) async {
    final changes = <Set<String>>[];
    const initial = <String>{'a'};
    await pump(tester, field(initialValue: initial, onChanged: changes.add));
    await tester.tap(find.text('Gamma'));
    await tester.pump();
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(changes, [
      {'a', 'c'},
      {'c'},
    ]);
    expect(initial, {'a'});
    expect(() => changes.first.add('x'), throwsUnsupportedError);
    expect(checked(tester), {'Gamma'});
  });

  testWidgets('required shows an announced error, tied as hint', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, field(required: true, helperText: 'Help'));
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Letters'))
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
          .getSemantics(find.bySemanticsLabel('Letters'))
          .getSemanticsData()
          .hint,
      'This field is required',
    );
    expect(
      find.ancestor(
        of: find.text('This field is required'),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.role == SemanticsRole.alert,
        ),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(key.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('This field is required'), findsNothing);
    handle.dispose();
  });

  testWidgets('an optional group is valid empty; the validator runs', (
    tester,
  ) async {
    await pump(
      tester,
      CheckboxGroupField<String>(
        label: 'Letters',
        options: _options,
        validator: (v) => (v?.length ?? 0) > 1 ? 'At most one' : null,
      ),
    );
    expect(key.currentState!.validate(), isTrue);
    await tester.tap(find.text('Alpha'));
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('At most one'), findsOneWidget);
  });

  testWidgets('Form save passes the value; reset restores the initial one', (
    tester,
  ) async {
    Set<String>? saved;
    await pump(tester, field(initialValue: {'a'}, onSaved: (v) => saved = v));
    await tester.tap(find.text('Gamma'));
    await tester.pump();
    key.currentState!.save();
    expect(saved, {'a', 'c'});
    key.currentState!.reset();
    await tester.pump();
    expect(checked(tester), {'Alpha'});
  });

  testWidgets('a disabled field ignores taps, skips validation, no error', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final changes = <Set<String>>[];
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
    expect(
      tester
          .getSemantics(find.text('Beta'))
          .getSemanticsData()
          .flagsCollection
          .isEnabled,
      Tristate.isFalse,
    );
    handle.dispose();
  });

  testWidgets('a disabled option ignores taps; the others still work', (
    tester,
  ) async {
    final changes = <Set<String>>[];
    await pump(
      tester,
      field(
        onChanged: changes.add,
        options: const [
          ChoiceOption(value: 'a', label: 'Alpha'),
          ChoiceOption(value: 'b', label: 'Beta', enabled: false),
        ],
      ),
    );
    await tester.tap(find.text('Beta'), warnIfMissed: false);
    await tester.pump();
    expect(changes, isEmpty);
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(changes, [
      {'a'},
    ]);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
    testWidgets('each option is 48 dp high and full width on $platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await pump(tester, field());
        for (final tile in tester.widgetList(find.byType(CheckboxListTile))) {
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
    final box = tester.getRect(find.byType(Checkbox).first);
    final label = tester.getRect(find.text('Alpha'));
    expect(box.center.dx, greaterThan(label.center.dx));
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
      tester.getSize(find.byType(CheckboxListTile).first).height,
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
    await tester.pumpWidget(
      formHost([
        field(initialValue: {'z'}),
      ]),
    );
    await tester.pump();
    expect(tester.takeException(), isA<AssertionError>());
  });
}
