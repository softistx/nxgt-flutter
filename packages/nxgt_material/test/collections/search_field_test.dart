import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/collections.dart';

import '../support/host.dart';

void main() {
  late List<String> emitted;
  late List<String> submitted;

  setUp(() {
    emitted = [];
    submitted = [];
  });

  SearchField field({
    Duration debounce = const Duration(milliseconds: 300),
    TextEditingController? controller,
    String? initialValue,
    String? hintText,
    bool enabled = true,
    bool autofocus = false,
    FocusNode? focusNode,
  }) => SearchField(
    onChanged: emitted.add,
    onSubmitted: submitted.add,
    debounce: debounce,
    controller: controller,
    initialValue: initialValue,
    hintText: hintText,
    enabled: enabled,
    autofocus: autofocus,
    focusNode: focusNode,
  );

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Locale locale = const Locale('en'),
    TextDirection? direction,
  }) => tester.pumpApp(themedHost(child, locale: locale, direction: direction));

  final clearButton = find.byType(IconButton);

  group('debounce', () {
    testWidgets('emits once, 300 ms after the last of rapid keystrokes', (
      tester,
    ) async {
      await pump(tester, field());
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(find.byType(TextField), 'abc');
      expect(emitted, isEmpty);
      await tester.pump(const Duration(milliseconds: 299));
      expect(emitted, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      expect(emitted, ['abc']);
      await tester.pump(const Duration(seconds: 2));
      expect(emitted, ['abc']);
    });

    testWidgets('Duration.zero emits at every keystroke', (tester) async {
      await pump(tester, field(debounce: Duration.zero));
      await tester.enterText(find.byType(TextField), 'a');
      await tester.enterText(find.byType(TextField), 'ab');
      expect(emitted, ['a', 'ab']);
    });

    testWidgets('a custom debounce is honoured', (tester) async {
      await pump(tester, field(debounce: const Duration(seconds: 1)));
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 900));
      expect(emitted, isEmpty);
      await tester.pump(const Duration(milliseconds: 100));
      expect(emitted, ['a']);
    });

    testWidgets('nothing is emitted after dispose', (tester) async {
      await pump(tester, field());
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(emitted, isEmpty);
    });

    testWidgets('a programmatic controller change does not emit', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(tester, field(controller: controller));
      controller.text = 'set by code';
      await tester.pump(const Duration(seconds: 1));
      expect(emitted, isEmpty);
    });
  });

  group('clear button', () {
    testWidgets('shows only when there is text', (tester) async {
      await pump(tester, field());
      expect(clearButton, findsNothing);
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      expect(clearButton, findsOneWidget);
    });

    testWidgets('shows for an initial value', (tester) async {
      await pump(tester, field(initialValue: 'abc'));
      expect(clearButton, findsOneWidget);
      expect(find.text('abc'), findsOneWidget);
    });

    testWidgets('emits an empty string at once, hides and keeps focus', (
      tester,
    ) async {
      await pump(tester, field(initialValue: 'abc'));
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'abcd');
      await tester.pump();
      await tester.tap(clearButton);
      await tester.pump();
      expect(emitted, ['']);
      expect(clearButton, findsNothing);
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.controller.text, '');
      expect(editable.focusNode.hasFocus, isTrue);
      await tester.pump(const Duration(seconds: 1));
      expect(emitted, ['']);
    });

    testWidgets('a disabled field has no clear button', (tester) async {
      await pump(tester, field(initialValue: 'abc', enabled: false));
      expect(clearButton, findsNothing);
    });
  });

  group('submit and keyboard', () {
    testWidgets('submit fires at once and cancels the pending debounce', (
      tester,
    ) async {
      await pump(tester, field());
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(submitted, ['abc']);
      await tester.pump(const Duration(seconds: 1));
      expect(emitted, isEmpty);
    });

    testWidgets('the keyboard action is search', (tester) async {
      await pump(tester, field());
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.textInputAction, TextInputAction.search);
    });

    testWidgets('autofocus takes the focus', (tester) async {
      await pump(tester, field(autofocus: true));
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.focusNode.hasFocus, isTrue);
    });
  });

  group('controller and focus node', () {
    testWidgets('an external controller is not disposed', (tester) async {
      final controller = TextEditingController(text: 'x');
      await pump(tester, field(controller: controller));
      await tester.pumpWidget(const SizedBox());
      controller
        ..text = 'still usable'
        ..dispose();
    });

    testWidgets('an external focus node is not disposed', (tester) async {
      final node = FocusNode();
      await pump(tester, field(focusNode: node));
      await tester.pumpWidget(const SizedBox());
      node
        ..requestFocus()
        ..dispose();
    });

    testWidgets('a swapped controller is followed', (tester) async {
      final a = TextEditingController(text: 'one');
      final b = TextEditingController();
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      await pump(tester, field(controller: a));
      expect(clearButton, findsOneWidget);
      await pump(tester, field(controller: b));
      expect(clearButton, findsNothing);
      b.text = 'two';
      await tester.pump();
      expect(clearButton, findsOneWidget);
      expect(find.text('two'), findsOneWidget);
      a.text = 'ignored';
      await tester.pump();
      expect(find.text('two'), findsOneWidget);
    });

    testWidgets('going from owned to external and back keeps working', (
      tester,
    ) async {
      final c = TextEditingController(text: 'ext');
      addTearDown(c.dispose);
      await pump(tester, field(initialValue: 'own'));
      expect(find.text('own'), findsOneWidget);
      await pump(tester, field(controller: c));
      expect(find.text('ext'), findsOneWidget);
      await pump(tester, field());
      expect(find.text('ext'), findsOneWidget);
      expect(clearButton, findsOneWidget);
    });

    testWidgets('an owned controller is disposed with the field', (
      tester,
    ) async {
      await pump(tester, field(initialValue: 'abc'));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });

  group('semantics', () {
    testWidgets('the hint is the label of the empty field', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, field());
      expect(find.bySemanticsLabel('Search'), findsWidgets);
      handle.dispose();
    });

    testWidgets('a custom hint is the label', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, field(hintText: 'Find a patient'));
      expect(find.bySemanticsLabel('Find a patient'), findsWidgets);
      expect(find.text('Find a patient'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('keeps an accessible name once text is typed', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, field(debounce: Duration.zero));
      await tester.enterText(find.byType(TextField), 'ana');
      await tester.pump();
      final data = tester
          .getSemantics(find.byType(EditableText))
          .getSemanticsData();
      expect(data.value, 'ana');
      expect(data.label, contains('Search'));
      handle.dispose();
    });

    testWidgets('the node is a text field of the search input type', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, field());
      final data = tester
          .getSemantics(find.byType(EditableText))
          .getSemanticsData();
      expect(data.flagsCollection.isTextField, isTrue);
      expect(data.inputType.name, 'search');
      handle.dispose();
    });

    testWidgets('the clear button is labelled', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, field(initialValue: 'abc'));
      expect(find.byTooltip('Clear search'), findsOneWidget);
      expect(
        tester.getSemantics(clearButton),
        matchesSemantics(
          tooltip: 'Clear search',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          textDirection: TextDirection.ltr,
        ),
      );
      handle.dispose();
    });

    testWidgets('speaks French', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        field(initialValue: 'abc'),
        locale: const Locale('fr'),
      );
      expect(find.byTooltip('Effacer la recherche'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the default hint is French in French', (tester) async {
      await pump(tester, field(), locale: const Locale('fr'));
      expect(find.text('Rechercher'), findsOneWidget);
    });
  });

  group('layout', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
      testWidgets('the clear button is 48 dp on $platform', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await pump(tester, field(initialValue: 'abc'));
          final size = tester.getSize(clearButton);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
          expect(
            tester.getSize(find.byType(TextField)).height,
            greaterThanOrEqualTo(48),
          );
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }

    testWidgets('the icons sit at the right edges in RTL', (tester) async {
      await pump(
        tester,
        field(initialValue: 'abc'),
        direction: TextDirection.rtl,
      );
      final field0 = tester.getRect(find.byType(TextField));
      final search = tester.getCenter(find.byIcon(Icons.search));
      final clear = tester.getCenter(find.byIcon(Icons.close));
      expect(search.dx, greaterThan(field0.center.dx));
      expect(clear.dx, lessThan(field0.center.dx));
    });

    testWidgets('holds at text scale 2', (tester) async {
      await tester.pumpApp(
        themedHost(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SizedBox(width: 320, child: field(initialValue: 'abc')),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(clearButton).height, greaterThanOrEqualTo(48));
    });

    testWidgets('lives inside an IntrinsicHeight', (tester) async {
      await pump(tester, IntrinsicHeight(child: field(initialValue: 'abc')));
      expect(tester.takeException(), isNull);
      expect(find.byType(SearchField), findsOneWidget);
    });
  });
}
