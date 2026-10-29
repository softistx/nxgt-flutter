import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/selection.dart';

import '../support/host.dart';

void main() {
  late GlobalKey<FormState> key;
  setUp(() => key = GlobalKey<FormState>());

  Future<void> pump(
    WidgetTester tester,
    SwitchField field, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(formHost([field], formKey: key, locale: locale));
    await tester.pumpAndSettle();
  }

  bool on(WidgetTester tester) =>
      tester.widget<Switch>(find.byType(Switch)).value;

  testWidgets('exposes label and toggled state to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const SwitchField(label: 'Notifications'));
    expect(
      tester.getSemantics(find.byType(Switch)),
      matchesSemantics(
        label: 'Notifications',
        hasToggledState: true,
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
      const SwitchField(label: 'Notifications', initialValue: true),
    );
    expect(
      tester.getSemantics(find.byType(Switch)),
      matchesSemantics(
        label: 'Notifications',
        hasToggledState: true,
        hasSelectedState: true,
        isToggled: true,
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
    final changes = <bool>[];
    await pump(
      tester,
      SwitchField(label: 'Notifications', onChanged: changes.add),
    );
    await tester.tap(find.text('Notifications'));
    await tester.pump();
    expect(on(tester), isTrue);
    await tester.tap(find.text('Notifications'));
    await tester.pump();
    expect(on(tester), isFalse);
    expect(changes, [true, false]);
  });

  testWidgets('Space toggles the focused switch', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    final changes = <bool>[];
    await pump(
      tester,
      SwitchField(
        label: 'Notifications',
        focusNode: node,
        onChanged: changes.add,
      ),
    );
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(on(tester), isTrue);
    expect(changes, [true]);
  });

  testWidgets('Form validate runs the validator and shows its error', (
    tester,
  ) async {
    await pump(
      tester,
      SwitchField(
        label: 'Notifications',
        validator: (v) => v == true ? null : 'Turn this on',
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Turn this on'), findsOneWidget);

    await tester.tap(find.text('Notifications'));
    await tester.pump();
    expect(key.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Turn this on'), findsNothing);
  });

  testWidgets('an off switch is valid without a validator', (tester) async {
    await pump(tester, const SwitchField(label: 'Notifications'));
    expect(key.currentState!.validate(), isTrue);
  });

  testWidgets('autovalidateMode always shows the error at once', (
    tester,
  ) async {
    await pump(
      tester,
      SwitchField(
        label: 'Notifications',
        validator: (_) => 'Nope',
        autovalidateMode: AutovalidateMode.always,
      ),
    );
    expect(find.text('Nope'), findsOneWidget);
  });

  testWidgets('Form save passes the value; reset restores the initial one', (
    tester,
  ) async {
    bool? saved;
    await pump(
      tester,
      SwitchField(label: 'Notifications', onSaved: (v) => saved = v),
    );
    await tester.tap(find.text('Notifications'));
    await tester.pump();
    key.currentState!.save();
    expect(saved, isTrue);

    key.currentState!.reset();
    await tester.pump();
    expect(on(tester), isFalse);
  });

  testWidgets('the switch reads the error, then the helper text, as hint', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      SwitchField(
        label: 'Notifications',
        helperText: 'Help',
        validator: (v) => v == true ? null : 'Turn this on',
      ),
    );
    expect(find.text('Help'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(Switch)).getSemanticsData().hint,
      'Help',
    );
    key.currentState!.validate();
    await tester.pump();
    final node = tester.getSemantics(find.byType(Switch)).getSemanticsData();
    expect(node.label, 'Notifications');
    expect(node.hint, 'Turn this on');
    expect(find.text('Help'), findsNothing);
    handle.dispose();
  });

  testWidgets('disabled ignores taps, skips validation and shows no error', (
    tester,
  ) async {
    final changes = <bool>[];
    await pump(
      tester,
      SwitchField(
        label: 'Notifications',
        enabled: false,
        validator: (_) => 'Nope',
        autovalidateMode: AutovalidateMode.always,
        onChanged: changes.add,
      ),
    );
    await tester.tap(find.text('Notifications'), warnIfMissed: false);
    await tester.pump();
    expect(on(tester), isFalse);
    expect(changes, isEmpty);
    expect(key.currentState!.validate(), isTrue);
    expect(find.text('Nope'), findsNothing);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
    testWidgets('is at least 48 dp high and full width on $platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await pump(tester, const SwitchField(label: 'Notifications'));
        final size = tester.getSize(find.byType(SwitchListTile));
        expect(size.height, greaterThanOrEqualTo(48));
        expect(size.width, tester.getSize(find.byType(Form)).width);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('keeps 48 dp under the compact desktop density', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      themedHost(
        Theme(
          data: ThemeData(visualDensity: VisualDensity.compact),
          child: const Form(child: SwitchField(label: 'Notifications')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(SwitchListTile)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('works in right-to-left', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      themedHost(
        Form(
          key: key,
          child: const SwitchField(label: 'Notifications'),
        ),
        direction: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final control = tester.getRect(find.byType(Switch));
    final label = tester.getRect(find.text('Notifications'));
    expect(control.center.dx, lessThan(label.center.dx));
  });

  testWidgets('is safe inside an IntrinsicHeight', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      formHost([
        const IntrinsicHeight(
          child: SwitchField(label: 'Notifications', helperText: 'Help'),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('works inside a coloured ancestor', (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      themedHost(
        const ColoredBox(
          color: Colors.amber,
          child: SwitchField(label: 'Notifications'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notifications'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
