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

  testWidgets('radii falls back to the defaults without a ThemeSpec', (
    tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(captured.radii.xs, 4);
    expect(captured.radii.xl, 28);
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

  testWidgets('tones fall back to the colour scheme, cached per scheme', (
    tester,
  ) async {
    late Tones first;
    late Tones second;
    final theme = ThemeData(colorSchemeSeed: Colors.indigo);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            first = context.tones;
            second = context.tones;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(identical(first, second), isTrue);
    expect(first.primary.color, theme.colorScheme.primary);
    expect(first.error.color, theme.colorScheme.error);
    expect(first, Tones.fromScheme(theme.colorScheme));
  });

  testWidgets('fonts and motif fall back to the ThemeSpec defaults', (
    tester,
  ) async {
    late ThemeFonts fonts;
    late ThemeMotif motif;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(),
        home: Builder(
          builder: (context) {
            fonts = context.fonts;
            motif = context.motif;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(fonts, const ThemeFonts());
    expect(motif, ThemeMotif.none);
  });

  testWidgets('TokenSheet swatches are labelled with tone and role', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemePresets.ocean.light(),
        home: const Scaffold(body: SingleChildScrollView(child: TokenSheet())),
      ),
    );

    expect(find.bySemanticsLabel('success color'), findsOneWidget);
    expect(find.bySemanticsLabel('warning container'), findsOneWidget);
    handle.dispose();
  });
}
