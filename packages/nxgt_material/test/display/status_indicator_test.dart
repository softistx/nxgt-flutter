import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

import '../support/host.dart';

void main() {
  testWidgets('StatusIndicator shows its label and a dot', (tester) async {
    await tester.pumpApp(themedHost(const StatusIndicator(label: 'Paid')));

    expect(find.text('Paid'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('StatusIndicator draws the tone icon with dot: false', (
    tester,
  ) async {
    await tester.pumpApp(
      themedHost(
        const StatusIndicator(
          label: 'Late',
          tone: FeedbackTone.error,
          dot: false,
        ),
      ),
    );

    expect(find.byIcon(FeedbackTone.error.icon), findsOneWidget);
  });

  testWidgets('StatusIndicator speaks the tone before the label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      themedHost(
        const StatusIndicator(label: 'Paid', tone: FeedbackTone.success),
      ),
    );

    expect(find.bySemanticsLabel('Success, Paid'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('StatusIndicator speaks the tone in French', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      themedHost(
        const StatusIndicator(label: 'Payé', tone: FeedbackTone.warning),
        locale: const Locale('fr'),
      ),
    );

    expect(find.bySemanticsLabel('Attention, Payé'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('StatusIndicator uses the tone container and on-colour', (
    tester,
  ) async {
    await tester.pumpApp(
      themedHost(
        const StatusIndicator(label: 'Paid', tone: FeedbackTone.success),
      ),
    );

    final context = tester.element(find.byType(StatusIndicator));
    final colors = FeedbackTone.success.colors(context.tones);
    final text = tester.widget<Text>(find.text('Paid'));
    expect(text.style?.color, colors.onContainer);
  });
}
