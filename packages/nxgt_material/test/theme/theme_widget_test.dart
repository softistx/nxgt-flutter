import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/theme.dart';

void main() {
  testWidgets('TokenSheet renders every tone under a preset', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemePresets.ocean.light(),
        home: const Scaffold(body: SingleChildScrollView(child: TokenSheet())),
      ),
    );

    expect(find.text('success'), findsOneWidget);
    expect(find.text('neutral'), findsOneWidget);
    expect(find.text('lg-plus'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('context accessors read the theme extensions', (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemePresets.corail.dark(),
        home: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(captured.tones, isA<Tones>());
    expect(captured.radii.base, 16);
    expect(captured.fonts.sans, 'SF Pro Rounded');
    expect(captured.motif.preset, BackgroundPreset.confettiGrid);
  });

  testWidgets('the theme animates between two presets', (tester) async {
    Widget app(ThemeData theme) => MaterialApp(
      theme: theme,
      home: const Scaffold(body: SingleChildScrollView(child: TokenSheet())),
    );
    await tester.pumpWidget(app(ThemePresets.ocean.light()));
    await tester.pumpWidget(app(ThemePresets.prune.dark()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });

  testWidgets('a theme without the extensions explains the fix', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(),
        home: Builder(
          builder: (context) {
            context.tones;
            return const SizedBox();
          },
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('ThemeSpec'));
  });
}
