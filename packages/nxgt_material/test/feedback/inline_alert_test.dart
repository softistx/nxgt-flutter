import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

import '../support/host.dart';

void main() {
  testWidgets('shows the title and the message in the tone colours', (
    tester,
  ) async {
    await tester.pumpApp(
      themedHost(
        const InlineAlert(
          tone: FeedbackTone.success,
          title: 'Saved',
          message: 'Your changes are live.',
        ),
      ),
    );

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Your changes are live.'), findsOneWidget);
    final context = tester.element(find.byType(InlineAlert));
    final tone = context.tones.success;
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(InlineAlert),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, tone.container);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.check_circle_outline)).color,
      tone.onContainer,
    );
  });

  testWidgets('each tone has its own icon, and the icon can be replaced', (
    tester,
  ) async {
    for (final tone in FeedbackTone.values) {
      await tester.pumpApp(themedHost(InlineAlert(tone: tone, message: 'm')));
      expect(find.byIcon(tone.icon), findsOneWidget, reason: tone.name);
    }
    await tester.pumpApp(
      themedHost(const InlineAlert(message: 'm', icon: Icons.lightbulb)),
    );
    expect(find.byIcon(Icons.lightbulb), findsOneWidget);
  });

  testWidgets('has no close button without onDismiss, and calls it', (
    tester,
  ) async {
    await tester.pumpApp(themedHost(const InlineAlert(message: 'm')));
    expect(find.byType(IconButton), findsNothing);

    var dismissed = 0;
    await tester.pumpApp(
      themedHost(InlineAlert(message: 'm', onDismiss: () => dismissed++)),
    );
    await tester.tap(find.byType(IconButton));
    expect(dismissed, 1);
  });

  testWidgets('shows its action', (tester) async {
    var pressed = 0;
    await tester.pumpApp(
      themedHost(
        InlineAlert(
          message: 'm',
          action: TextButton(
            onPressed: () => pressed++,
            child: const Text('Undo'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Undo'));
    expect(pressed, 1);
  });

  testWidgets('works in dark and speaks French', (tester) async {
    await tester.pumpApp(
      themedHost(
        const InlineAlert(message: 'm', onDismiss: _noop),
        brightness: Brightness.dark,
        locale: const Locale('fr'),
      ),
    );

    expect(find.byTooltip('Fermer'), findsOneWidget);
  });

  group('semantics', () {
    testWidgets('error and warning are alerts, info and success statuses', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      for (final tone in FeedbackTone.values) {
        await tester.pumpApp(
          themedHost(InlineAlert(tone: tone, message: 'Hello')),
        );
        final data = tester
            .getSemantics(find.byType(InlineAlert))
            .getSemanticsData();
        expect(data.role, switch (tone) {
          FeedbackTone.error || FeedbackTone.warning => SemanticsRole.alert,
          FeedbackTone.info || FeedbackTone.success => SemanticsRole.status,
        }, reason: tone.name);
        expect(
          tester.getSemantics(find.text('Hello')),
          isSemantics(isLiveRegion: true),
          reason: tone.name,
        );
      }
      handle.dispose();
    });

    testWidgets('the tone is spoken before the title and the message', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        themedHost(
          const InlineAlert(
            tone: FeedbackTone.error,
            title: 'Payment failed',
            message: 'Card declined.',
          ),
        ),
      );

      final label = tester.getSemantics(find.text('Card declined.')).label;
      expect(label, contains('Error'));
      expect(label.indexOf('Error'), lessThan(label.indexOf('Payment failed')));
      expect(
        label.indexOf('Payment failed'),
        lessThan(label.indexOf('Card declined.')),
      );
      handle.dispose();
    });

    testWidgets('the close button is a labelled button of at least 48 dp', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        themedHost(InlineAlert(message: 'm', onDismiss: () {})),
      );

      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(tooltip: 'Close', isButton: true, isEnabled: true),
      );
      final size = tester.getSize(find.byType(IconButton));
      expect(size.shortestSide, greaterThanOrEqualTo(48));
      handle.dispose();
    });
  });

  testWidgets('works under a bare MaterialApp, with tones from the scheme', (
    tester,
  ) async {
    await tester.pumpApp(
      const MaterialApp(
        home: Scaffold(
          body: InlineAlert(tone: FeedbackTone.warning, message: 'm'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final context = tester.element(find.byType(InlineAlert));
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(InlineAlert),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, context.tones.warning.container);
  });
}

void _noop() {}
