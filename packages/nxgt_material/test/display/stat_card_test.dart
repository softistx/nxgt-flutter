import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/src/theme/contrast.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';
import 'package:nxgt_material/src/theme/tone_colors.dart';

import '../support/host.dart';

void main() {
  Widget card({
    String? delta = '4 %',
    StatTrend? trend = StatTrend.up,
    bool positiveIsUp = true,
    VoidCallback? onTap,
    IconData? icon,
  }) => StatCard(
    label: 'Revenue',
    value: '1 200',
    delta: delta,
    trend: trend,
    positiveIsUp: positiveIsUp,
    icon: icon,
    onTap: onTap,
  );

  testWidgets('StatCard shows label, value, delta and icons', (tester) async {
    await tester.pumpApp(themedHost(card(icon: Icons.payments_outlined)));

    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('1 200'), findsOneWidget);
    expect(find.text('4 %'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
    expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
  });

  group('merged semantics', () {
    testWidgets('speak label, value, trend word and delta in English', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(themedHost(card()));

      expect(find.bySemanticsLabel('Revenue, 1 200, up 4 %'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('speak the trend words in French', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        themedHost(card(trend: StatTrend.down), locale: const Locale('fr')),
      );

      expect(
        find.bySemanticsLabel('Revenue, 1 200, en baisse 4 %'),
        findsOneWidget,
      );
      handle.dispose();
    });

    for (final (trend, word) in [
      (StatTrend.up, 'up'),
      (StatTrend.down, 'down'),
      (StatTrend.flat, 'unchanged'),
    ]) {
      testWidgets('say "$word" for $trend, with its own icon', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpApp(themedHost(card(trend: trend)));

        expect(
          find.bySemanticsLabel('Revenue, 1 200, $word 4 %'),
          findsOneWidget,
        );
        expect(find.byIcon(trend.icon), findsOneWidget);
        handle.dispose();
      });
    }

    testWidgets('say the word alone without a delta, and only the '
        'figure without a trend', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(themedHost(card(delta: null)));
      expect(find.bySemanticsLabel('Revenue, 1 200, up'), findsOneWidget);

      await tester.pumpApp(themedHost(card(delta: null, trend: null)));
      expect(find.bySemanticsLabel('Revenue, 1 200'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('are one node', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(themedHost(card(icon: Icons.payments_outlined)));

      expect(find.text('4 %'), findsOneWidget);
      expect(find.semantics.byLabel('4 %'), findsNothing);
      expect(find.semantics.byLabel('Revenue'), findsNothing);
      handle.dispose();
    });
  });

  group('onTap', () {
    testWidgets('makes a button that calls back', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpApp(themedHost(card(onTap: () => taps++)));

      final node = tester.getSemantics(
        find.bySemanticsLabel('Revenue, 1 200, up 4 %'),
      );
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

      await tester.tap(find.byType(StatCard));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('is focusable and at least 48 dp', (tester) async {
      await tester.pumpApp(themedHost(card(onTap: () {})));

      expect(find.byType(InkWell), findsOneWidget);
      final size = tester.getSize(find.byType(InkWell));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    });

    testWidgets('without it is neither a button nor focusable', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(themedHost(card()));

      final node = tester.getSemantics(
        find.bySemanticsLabel('Revenue, 1 200, up 4 %'),
      );
      expect(node.flagsCollection.isButton, isFalse);
      expect(find.byType(InkWell), findsNothing);
      handle.dispose();
    });
  });

  testWidgets('StatCard keeps 48 dp even when empty-ish', (tester) async {
    await tester.pumpApp(
      themedHost(
        const Align(
          child: StatCard(label: '', value: ''),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(StatCard)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('StatCard puts the icon at the end of the label row in both '
      'directions', (tester) async {
    Future<(double, double)> xs(TextDirection direction) async {
      await tester.pumpApp(
        themedHost(
          Directionality(
            textDirection: direction,
            child: card(icon: Icons.payments_outlined),
          ),
        ),
      );
      return (
        tester.getCenter(find.text('Revenue')).dx,
        tester.getCenter(find.byIcon(Icons.payments_outlined)).dx,
      );
    }

    final (labelLtr, iconLtr) = await xs(TextDirection.ltr);
    expect(iconLtr, greaterThan(labelLtr));
    final (labelRtl, iconRtl) = await xs(TextDirection.rtl);
    expect(iconRtl, lessThan(labelRtl));
  });

  group('tones', () {
    ToneColors? pill(WidgetTester tester) {
      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(of: find.text('4 %'), matching: find.byType(DecoratedBox))
            .first,
      );
      final color = (box.decoration as ShapeDecoration).color;
      final tones = tester.element(find.byType(StatCard)).tones;
      for (final tone in [tones.success, tones.error, tones.neutral]) {
        if (tone.container == color) return tone;
      }
      return null;
    }

    testWidgets('are success up, error down, neutral flat', (tester) async {
      await tester.pumpApp(themedHost(card()));
      final tones = tester.element(find.byType(StatCard)).tones;
      expect(pill(tester), tones.success);

      await tester.pumpApp(themedHost(card(trend: StatTrend.down)));
      expect(pill(tester), tones.error);

      await tester.pumpApp(themedHost(card(trend: StatTrend.flat)));
      expect(pill(tester), tones.neutral);
    });

    testWidgets('swap with positiveIsUp false', (tester) async {
      await tester.pumpApp(themedHost(card(positiveIsUp: false)));
      final tones = tester.element(find.byType(StatCard)).tones;
      expect(pill(tester), tones.error);

      await tester.pumpApp(
        themedHost(card(trend: StatTrend.down, positiveIsUp: false)),
      );
      expect(pill(tester), tones.success);
    });

    for (final brightness in Brightness.values) {
      testWidgets('reach AA contrast in ${brightness.name}', (tester) async {
        await tester.pumpApp(themedHost(card(), brightness: brightness));
        final tones = tester.element(find.byType(StatCard)).tones;

        for (final trend in StatTrend.values) {
          for (final positiveIsUp in [true, false]) {
            final colors = trend.colors(tones, positiveIsUp: positiveIsUp);
            expect(
              wcagContrast(colors.onContainer, colors.container),
              greaterThanOrEqualTo(4.5),
              reason: '$trend positiveIsUp=$positiveIsUp',
            );
          }
        }
      });
    }
  });
}
