import 'dart:ui' show Tristate;

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
    Widget field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pump();
  }

  SemanticsData data(WidgetTester tester, String text) =>
      tester.getSemantics(find.text(text)).getSemanticsData();

  group('ChoiceChipsField', () {
    ChoiceChipsField<String> field({
      String? initialValue,
      ValueChanged<String?>? onChanged,
      bool required = false,
      bool enabled = true,
      List<ChoiceOption<String>> options = _options,
      String? helperText,
      FormFieldSetter<String?>? onSaved,
      AutovalidateMode? autovalidateMode,
      FocusNode? focusNode,
    }) => ChoiceChipsField<String>(
      label: 'Letter',
      options: options,
      initialValue: initialValue,
      onChanged: onChanged,
      required: required,
      enabled: enabled,
      helperText: helperText,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      focusNode: focusNode,
    );

    testWidgets('the group has a labelled container, each chip its state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, field(initialValue: 'b'));
      expect(find.text('Letter'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Letter'))
            .getSemanticsData()
            .label,
        'Letter',
      );
      final alpha = data(tester, 'Alpha');
      expect(alpha.label, contains('Alpha'));
      expect(alpha.flagsCollection.isSelected, Tristate.isFalse);
      expect(alpha.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(alpha.flagsCollection.isButton, isTrue);
      final beta = data(tester, 'Beta');
      expect(beta.flagsCollection.isSelected, Tristate.isTrue);
      expect(beta.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      handle.dispose();
    });

    testWidgets('the description is the tooltip, not visible text', (
      tester,
    ) async {
      await pump(tester, field());
      expect(find.text('First'), findsNothing);
      expect(
        tester.widget<ChoiceChip>(find.byType(ChoiceChip).first).tooltip,
        'First',
      );
      expect(
        tester.widget<ChoiceChip>(find.byType(ChoiceChip).at(1)).tooltip,
        isNull,
      );
    });

    testWidgets('a tap chooses a chip; tapping it again clears it', (
      tester,
    ) async {
      final changes = <String?>[];
      await pump(tester, field(onChanged: changes.add));
      await tap(tester, 'Beta');
      await tap(tester, 'Gamma');
      await tap(tester, 'Gamma');
      expect(changes, ['b', 'c', null]);
      expect(
        tester
            .widgetList<ChoiceChip>(find.byType(ChoiceChip))
            .where((c) => c.selected),
        isEmpty,
      );
    });

    testWidgets('a required field keeps its choice when it is tapped again', (
      tester,
    ) async {
      final changes = <String?>[];
      await pump(
        tester,
        field(initialValue: 'a', required: true, onChanged: changes.add),
      );
      await tap(tester, 'Alpha');
      expect(changes, isEmpty);
      expect(
        tester.widget<ChoiceChip>(find.byType(ChoiceChip).first).selected,
        isTrue,
      );
      expect(key.currentState!.validate(), isTrue);
    });

    testWidgets('required shows an announced error, tied as hint', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, field(required: true, helperText: 'Help'));
      String hint() => tester
          .getSemantics(find.bySemanticsLabel('Letter'))
          .getSemanticsData()
          .hint;
      expect(hint(), 'Help');
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);
      expect(find.text('Help'), findsNothing);
      expect(hint(), 'This field is required');
      final alert = find.ancestor(
        of: find.text('This field is required'),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.role == SemanticsRole.alert,
        ),
      );
      expect(alert, findsOneWidget);
      expect(
        data(tester, 'This field is required').flagsCollection.isLiveRegion,
        isTrue,
      );
      await tap(tester, 'Alpha');
      expect(key.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('This field is required'), findsNothing);
      handle.dispose();
    });

    testWidgets('Form save passes the value; reset restores the initial one', (
      tester,
    ) async {
      String? saved;
      await pump(tester, field(initialValue: 'a', onSaved: (v) => saved = v));
      await tap(tester, 'Gamma');
      key.currentState!.save();
      expect(saved, 'c');
      key.currentState!.reset();
      await tester.pump();
      final selected = tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .map((c) => c.selected);
      expect(selected, [true, false, false]);
    });

    testWidgets('the validator runs after the required check', (tester) async {
      await pump(
        tester,
        ChoiceChipsField<String>(
          label: 'Letter',
          options: _options,
          validator: (v) => v == 'a' ? 'Not that one' : null,
        ),
      );
      expect(key.currentState!.validate(), isTrue);
      await tap(tester, 'Alpha');
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Not that one'), findsOneWidget);
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
      expect(data(tester, 'Beta').flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('a disabled option is not chosen and skipped by Tab', (
      tester,
    ) async {
      final changes = <String?>[];
      await pump(
        tester,
        field(
          onChanged: changes.add,
          options: const [
            ChoiceOption(value: 'a', label: 'Alpha', enabled: false),
            ChoiceOption(value: 'b', label: 'Beta'),
          ],
        ),
      );
      await tester.tap(find.text('Alpha'), warnIfMissed: false);
      await tester.pump();
      expect(changes, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(changes, ['b']);
    });

    testWidgets('Tab reaches a chip; Space and Enter toggle it', (
      tester,
    ) async {
      final changes = <String?>[];
      await pump(tester, field(onChanged: changes.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(changes, ['a', null]);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(changes, ['a', null, 'b']);
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
      testWidgets('each chip is at least 48 dp high on $platform', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await pump(tester, field());
          for (final chip in tester.widgetList(find.byType(ChoiceChip))) {
            final size = tester.getSize(find.byWidget(chip));
            expect(size.height, greaterThanOrEqualTo(48));
            expect(size.width, greaterThanOrEqualTo(48));
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
      expect(
        tester.getRect(find.text('Alpha')).center.dx,
        greaterThan(tester.getRect(find.text('Beta')).center.dx),
      );
    });

    testWidgets('wraps at text scale 2 without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(
        tester,
        field(
          required: true,
          helperText: 'Required to continue',
          options: [
            for (final n in ['One', 'Two', 'Three', 'Four'])
              ChoiceOption(value: n, label: 'A rather long option $n'),
          ],
        ),
      );
      key.currentState!.validate();
      await tester.pump();
      expect(tester.takeException(), isNull);
      final tops = {
        for (final chip in tester.widgetList(find.byType(ChoiceChip)))
          tester.getTopLeft(find.byWidget(chip)).dy,
      };
      expect(tops.length, greaterThan(1));
    });

    testWidgets('is safe inside an IntrinsicHeight', (tester) async {
      await pump(tester, IntrinsicHeight(child: field(helperText: 'Help')));
      expect(tester.takeException(), isNull);
    });

    testWidgets('works inside a coloured ancestor', (tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        themedHost(ColoredBox(color: Colors.amber, child: field())),
      );
      await tester.pumpAndSettle();
      await tap(tester, 'Alpha');
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
      await pump(
        tester,
        field(
          options: const [
            ChoiceOption(value: 'a', label: 'One'),
            ChoiceOption(value: 'a', label: 'Two'),
          ],
        ),
      );
      expect(tester.takeException(), isA<AssertionError>());
      await pump(tester, field(initialValue: 'z'));
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('focusNode goes to the first enabled option, if any', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      Future<void> show(List<bool> enabled, {bool fieldEnabled = true}) => pump(
        tester,
        field(
          focusNode: node,
          enabled: fieldEnabled,
          options: [
            for (final (i, e) in enabled.indexed)
              ChoiceOption(value: 'v$i', label: 'Option $i', enabled: e),
          ],
        ),
      );

      await show([false, true, true]);
      expect(
        tester
            .getRect(find.byType(ChoiceChip).at(1))
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
            .getRect(find.byType(ChoiceChip).first)
            .contains(node.rect.center),
        isTrue,
      );
    });
  });

  group('FilterChipsField', () {
    FilterChipsField<String> field({
      Set<String> initialValue = const {},
      ValueChanged<Set<String>>? onChanged,
      bool required = false,
      bool enabled = true,
      List<ChoiceOption<String>> options = _options,
      FormFieldSetter<Set<String>>? onSaved,
      FocusNode? focusNode,
    }) => FilterChipsField<String>(
      label: 'Letters',
      options: options,
      initialValue: initialValue,
      onChanged: onChanged,
      required: required,
      enabled: enabled,
      onSaved: onSaved,
      focusNode: focusNode,
    );

    testWidgets('the group has a labelled container, each chip its state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, field(initialValue: {'b'}));
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Letters'))
            .getSemanticsData()
            .label,
        'Letters',
      );
      final alpha = data(tester, 'Alpha');
      expect(alpha.flagsCollection.isSelected, Tristate.isFalse);
      expect(alpha.flagsCollection.isInMutuallyExclusiveGroup, isFalse);
      expect(alpha.flagsCollection.isButton, isTrue);
      expect(data(tester, 'Beta').flagsCollection.isSelected, Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('taps toggle chips and report sets in option order', (
      tester,
    ) async {
      final changes = <Set<String>>[];
      await pump(tester, field(onChanged: changes.add));
      await tap(tester, 'Gamma');
      await tap(tester, 'Alpha');
      await tap(tester, 'Gamma');
      expect(changes, [
        {'c'},
        {'a', 'c'},
        {'a'},
      ]);
      expect(changes[1].toList(), ['a', 'c']);
      expect(() => changes[0].add('x'), throwsUnsupportedError);
    });

    testWidgets('required shows an announced error until something is chosen', (
      tester,
    ) async {
      await pump(tester, field(required: true));
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);
      await tap(tester, 'Beta');
      expect(key.currentState!.validate(), isTrue);
      await tap(tester, 'Beta');
      expect(key.currentState!.validate(), isFalse);
    });

    testWidgets('Form save passes the set; reset restores the initial one', (
      tester,
    ) async {
      Set<String>? saved;
      await pump(tester, field(initialValue: {'a'}, onSaved: (v) => saved = v));
      await tap(tester, 'Gamma');
      key.currentState!.save();
      expect(saved, {'a', 'c'});
      key.currentState!.reset();
      await tester.pump();
      expect(
        tester
            .widgetList<FilterChip>(find.byType(FilterChip))
            .map((c) => c.selected),
        [true, false, false],
      );
    });

    testWidgets('a disabled field and a disabled option ignore taps', (
      tester,
    ) async {
      final changes = <Set<String>>[];
      await pump(tester, field(enabled: false, onChanged: changes.add));
      await tester.tap(find.text('Beta'), warnIfMissed: false);
      await tester.pump();
      expect(changes, isEmpty);
      await pump(
        tester,
        field(
          onChanged: changes.add,
          options: const [
            ChoiceOption(value: 'a', label: 'Alpha', enabled: false),
            ChoiceOption(value: 'b', label: 'Beta'),
          ],
        ),
      );
      await tester.tap(find.text('Alpha'), warnIfMissed: false);
      await tester.pump();
      expect(changes, isEmpty);
    });

    testWidgets('Tab reaches a chip; Space and Enter toggle it', (
      tester,
    ) async {
      final changes = <Set<String>>[];
      await pump(tester, field(onChanged: changes.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(changes, [
        {'a'},
        {'a', 'b'},
      ]);
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
      testWidgets('each chip is at least 48 dp high on $platform', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await pump(tester, field());
          for (final chip in tester.widgetList(find.byType(FilterChip))) {
            expect(
              tester.getSize(find.byWidget(chip)).height,
              greaterThanOrEqualTo(48),
            );
          }
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }

    testWidgets('RTL, text scale 2, IntrinsicHeight and ColoredBox hold', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        themedHost(
          ColoredBox(
            color: Colors.amber,
            child: Form(
              key: key,
              child: IntrinsicHeight(
                child: field(
                  required: true,
                  options: [
                    for (final n in ['One', 'Two', 'Three', 'Four'])
                      ChoiceOption(value: n, label: 'A rather long option $n'),
                  ],
                ),
              ),
            ),
          ),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      key.currentState!.validate();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.byType(FilterChip).first).right,
        greaterThan(700),
      );
    });

    testWidgets('speaks French', (tester) async {
      await pump(tester, field(required: true), locale: const Locale('fr'));
      key.currentState!.validate();
      await tester.pump();
      expect(find.text('Ce champ est obligatoire'), findsOneWidget);
    });

    testWidgets('asserts on duplicates and a foreign initial value', (
      tester,
    ) async {
      await pump(
        tester,
        field(
          options: const [
            ChoiceOption(value: 'a', label: 'One'),
            ChoiceOption(value: 'a', label: 'Two'),
          ],
        ),
      );
      expect(tester.takeException(), isA<AssertionError>());
      await pump(tester, field(initialValue: {'z'}));
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('focusNode goes to the first enabled option, if any', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pump(
        tester,
        field(
          focusNode: node,
          options: const [
            ChoiceOption(value: 'a', label: 'Alpha', enabled: false),
            ChoiceOption(value: 'b', label: 'Beta'),
          ],
        ),
      );
      expect(
        tester
            .getRect(find.byType(FilterChip).at(1))
            .contains(node.rect.center),
        isTrue,
      );
      await pump(tester, field(focusNode: node, enabled: false));
      expect(node.context?.mounted ?? false, isFalse);
    });
  });
}
