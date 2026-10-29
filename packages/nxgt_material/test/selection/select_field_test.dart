import 'dart:ui' show Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/selection.dart';

import '../support/host.dart';

const List<ChoiceOption<String>> _options = [
  ChoiceOption(value: 'a', label: 'Alpha', description: 'First'),
  ChoiceOption(value: 'b', label: 'Beta'),
  ChoiceOption(value: 'c', label: 'Gamma', enabled: false),
  ChoiceOption(value: 'e', label: 'Élan'),
];

final List<ChoiceOption<int>> _many = [
  for (var i = 1; i <= 15; i++) ChoiceOption(value: i, label: 'Item $i'),
];

void main() {
  late GlobalKey<FormState> key;
  setUp(() => key = GlobalKey<FormState>());

  Future<void> size(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pump(
    WidgetTester tester,
    Widget field, {
    double width = 800,
    Locale locale = const Locale('en'),
  }) async {
    await size(tester, width);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  SelectField<String> field({
    String? initialValue,
    ValueChanged<String?>? onChanged,
    bool required = false,
    bool enabled = true,
    bool searchable = false,
    String? helperText,
    FormFieldSetter<String?>? onSaved,
    FocusNode? focusNode,
    AutovalidateMode? autovalidateMode,
    List<ChoiceOption<String>> options = _options,
  }) => SelectField<String>(
    label: 'Letter',
    options: options,
    initialValue: initialValue,
    onChanged: onChanged,
    required: required,
    enabled: enabled,
    searchable: searchable,
    helperText: helperText,
    onSaved: onSaved,
    focusNode: focusNode,
    autovalidateMode: autovalidateMode,
  );

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
  }

  testWidgets('reads the label and the chosen value', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, field(initialValue: 'b'));
    expect(find.text('Letter'), findsOneWidget);
    final data = tester.getSemantics(find.text('Letter')).getSemanticsData();
    expect(data.label, contains('Letter'));
    expect(data.value, 'Beta');
    handle.dispose();
  });

  testWidgets('the field fills the parent width', (tester) async {
    await pump(tester, field());
    final box = tester.getSize(find.byType(DropdownMenu<String>));
    expect(box.width, 800);
  });

  testWidgets('the menu chooses an option on a medium window', (tester) async {
    final changes = <String?>[];
    await pump(tester, field(onChanged: changes.add));
    await openMenu(tester);
    expect(find.text('First'), findsOneWidget);
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();
    expect(changes, ['b']);
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('a disabled option is shown but not chosen', (tester) async {
    final changes = <String?>[];
    await pump(tester, field(onChanged: changes.add));
    await openMenu(tester);
    await tester.tap(find.text('Gamma').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });

  testWidgets('a searchable menu filters while typing', (tester) async {
    await pump(tester, field(searchable: true));
    await tester.enterText(find.byType(TextField), 'bet');
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsWidgets);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('a clear button returns to null unless required', (tester) async {
    final changes = <String?>[];
    await pump(tester, field(initialValue: 'a', onChanged: changes.add));
    await tester.tap(find.byTooltip('Clear selection'));
    await tester.pumpAndSettle();
    expect(changes, [null]);
    expect(find.byTooltip('Clear selection'), findsNothing);
    final menu = tester.widget<DropdownMenu<String>>(
      find.byType(DropdownMenu<String>),
    );
    expect(menu.controller!.text, '');
  });

  testWidgets('a required field has no clear button', (tester) async {
    await pump(tester, field(initialValue: 'a', required: true));
    expect(find.byTooltip('Clear selection'), findsNothing);
  });

  testWidgets('the clear action is offered to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    final changes = <String?>[];
    await pump(tester, field(initialValue: 'a', onChanged: changes.add));
    final id = tester.getSemantics(find.text('Letter')).id;
    final actions = tester
        .getSemantics(find.text('Letter'))
        .getSemanticsData()
        .customSemanticsActionIds;
    expect(actions, isNotEmpty);
    expect(id, isNonZero);
    handle.dispose();
  });

  testWidgets('required announces its error once, as the hint', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, field(required: true));
    expect(key.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsOneWidget);
    final data = tester.getSemantics(find.text('Letter')).getSemanticsData();
    expect(data.hint, 'This field is required');
    expect(find.bySemanticsLabel('This field is required'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the helper text is the hint and shows once', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, field(helperText: 'Pick one'));
    expect(find.text('Pick one'), findsOneWidget);
    final data = tester.getSemantics(find.text('Letter')).getSemanticsData();
    expect(data.hint, 'Pick one');
    handle.dispose();
  });

  testWidgets('a disabled field ignores input and is not validated', (
    tester,
  ) async {
    await pump(tester, field(enabled: false, required: true));
    expect(key.currentState!.validate(), isTrue);
    await tester.tap(find.byType(DropdownMenu<String>), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsNothing);
  });

  testWidgets('Form save and reset follow the value', (tester) async {
    final saved = <String?>[];
    await pump(tester, field(initialValue: 'a', onSaved: saved.add));
    await openMenu(tester);
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();
    key.currentState!.save();
    key.currentState!.reset();
    await tester.pumpAndSettle();
    key.currentState!.save();
    expect(saved, ['b', 'a']);
    expect(find.text('Alpha'), findsOneWidget);
  });

  testWidgets('the focusNode takes the focus of the control', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pump(tester, field(focusNode: node));
    node.requestFocus();
    await tester.pump();
    expect(node.hasFocus, isTrue);
  });

  for (final open in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
    testWidgets('${open.debugName} opens the menu, Enter chooses', (
      tester,
    ) async {
      final changes = <String?>[];
      final node = FocusNode();
      addTearDown(node.dispose);
      await pump(tester, field(focusNode: node, onChanged: changes.add));
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(open);
      await tester.pumpAndSettle();
      expect(find.text('Beta'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(changes, ['a']);
    });
  }

  testWidgets('Escape closes the open menu', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pump(tester, field(focusNode: node));
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsNothing);
  });

  group('sheet on a compact window', () {
    testWidgets('a searchable field opens a sheet and chooses', (tester) async {
      final changes = <String?>[];
      await pump(
        tester,
        field(searchable: true, onChanged: changes.add),
        width: 400,
      );
      expect(find.byType(DropdownMenu<String>), findsNothing);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(changes, ['b']);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('more than 12 options use the sheet without searchable', (
      tester,
    ) async {
      final changes = <int?>[];
      await size(tester, 400);
      await tester.pumpWidget(
        formHost([
          SelectField<int>(
            label: 'Item',
            options: _many,
            onChanged: changes.add,
          ),
        ]),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Item 3'));
      await tester.pumpAndSettle();
      expect(changes, [3]);
    });

    testWidgets('few options and not searchable keep the menu', (tester) async {
      await pump(tester, field(), width: 400);
      expect(find.byType(DropdownMenu<String>), findsOneWidget);
    });

    testWidgets('search ignores case and accents', (tester) async {
      await pump(tester, field(searchable: true), width: 400);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Search'), 'ELAN');
      await tester.pumpAndSettle();
      expect(find.text('Élan'), findsOneWidget);
      expect(find.text('Alpha'), findsNothing);
    });

    testWidgets('the selected tile is marked and options are 48 dp', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        field(searchable: true, initialValue: 'b'),
        width: 400,
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      final beta = tester
          .getSemantics(find.text('Beta').last)
          .getSemanticsData();
      expect(beta.flagsCollection.isSelected, Tristate.isTrue);
      expect(
        tester.getSize(find.widgetWithText(ListTile, 'Alpha')).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });

    testWidgets('a disabled option is not chosen', (tester) async {
      final changes = <String?>[];
      await pump(
        tester,
        field(searchable: true, onChanged: changes.add),
        width: 400,
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gamma'));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('closing keeps the old value', (tester) async {
      final changes = <String?>[];
      await pump(
        tester,
        field(searchable: true, initialValue: 'a', onChanged: changes.add),
        width: 400,
      );
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('Enter opens the sheet from the keyboard', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pump(tester, field(searchable: true, focusNode: node), width: 400);
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('a clear button works in the sheet mode too', (tester) async {
      final changes = <String?>[];
      await pump(
        tester,
        field(searchable: true, initialValue: 'a', onChanged: changes.add),
        width: 400,
      );
      await tester.tap(find.byTooltip('Clear selection'));
      await tester.pumpAndSettle();
      expect(changes, [null]);
    });

    testWidgets('a disabled field does not open', (tester) async {
      await pump(tester, field(searchable: true, enabled: false), width: 400);
      await tester.tap(find.byType(TextField), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsNothing);
    });
  });

  testWidgets('the control is at least 48 dp under macOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await pump(tester, field(initialValue: 'a'));
      final box = tester.getSize(find.byType(TextField));
      expect(box.height, greaterThanOrEqualTo(48));
      final clear = tester.getSize(find.byTooltip('Clear selection'));
      expect(clear.height, greaterThanOrEqualTo(48));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('lays out in right-to-left', (tester) async {
    await size(tester, 800);
    await tester.pumpWidget(
      themedHost(
        Form(child: field(initialValue: 'a')),
        direction: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final label = tester.getTopLeft(find.text('Letter'));
    expect(label.dx, greaterThan(400));
  });

  testWidgets('holds at text scale 2', (tester) async {
    await size(tester, 800);
    await tester.pumpWidget(
      themedHost(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(2),
            size: Size(800, 900),
          ),
          child: Form(
            child: field(initialValue: 'a', helperText: 'Pick one'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('works inside an IntrinsicHeight and a ColoredBox', (
    tester,
  ) async {
    await size(tester, 800);
    await tester.pumpWidget(
      themedHost(
        ColoredBox(
          color: Colors.blue,
          child: IntrinsicHeight(
            child: Form(child: field(initialValue: 'a')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('speaks French', (tester) async {
    await pump(
      tester,
      field(required: true, searchable: true),
      width: 400,
      locale: const Locale('fr'),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Ce champ est obligatoire'), findsOneWidget);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(find.text('Rechercher'), findsOneWidget);
  });

  group('asserts', () {
    testWidgets('duplicate values', (tester) async {
      await size(tester, 800);
      await tester.pumpWidget(
        formHost([
          field(
            options: const [
              ChoiceOption(value: 'a', label: 'A'),
              ChoiceOption(value: 'a', label: 'B'),
            ],
          ),
        ]),
      );
      await tester.pump();
      expect(
        tester.takeException(),
        isA<AssertionError>().having(
          (e) => e.message,
          'message',
          'SelectField.options must have unique values.',
        ),
      );
    });

    testWidgets('empty options', (tester) async {
      await size(tester, 800);
      await tester.pumpWidget(formHost([field(options: const [])]));
      await tester.pump();
      expect(
        tester.takeException(),
        isA<AssertionError>().having(
          (e) => e.message,
          'message',
          'SelectField.options must not be empty.',
        ),
      );
    });

    testWidgets('initialValue outside the options', (tester) async {
      await size(tester, 800);
      await tester.pumpWidget(formHost([field(initialValue: 'zzz')]));
      await tester.pump();
      expect(
        tester.takeException(),
        isA<AssertionError>().having(
          (e) => e.message,
          'message',
          'SelectField.initialValue must be one of the options.',
        ),
      );
    });
  });
}
