import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

import '../support/host.dart';

void main() {
  Widget host(
    void Function(BuildContext context) show, {
    Locale locale = const Locale('en'),
  }) => themedHost(
    Builder(
      builder: (context) =>
          TextButton(onPressed: () => show(context), child: const Text('go')),
    ),
    locale: locale,
  );

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('shows the message in a SnackBar', (tester) async {
    await tester.pumpApp(host((c) => c.showToast('Saved')));
    await open(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('a tone tints the SnackBar and adds its icon', (tester) async {
    await tester.pumpApp(
      host((c) => c.showToast('Saved', tone: FeedbackTone.success)),
    );
    await open(tester);

    final tones = tester.element(find.byType(SnackBar)).tones;
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      tones.success.container,
    );
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('a new toast replaces the one on screen', (tester) async {
    await tester.pumpApp(
      host((c) {
        c
          ..showToast('first')
          ..showToast('second');
      }),
    );
    await open(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('second'), findsOneWidget);
    expect(find.text('first'), findsNothing);
  });

  testWidgets('the action runs its callback', (tester) async {
    var undone = 0;
    await tester.pumpApp(
      host(
        (c) => c.showToast(
          'Deleted',
          actionLabel: 'Undo',
          onAction: () => undone++,
        ),
      ),
    );
    await open(tester);

    await tester.tap(find.text('Undo'));
    expect(undone, 1);
  });

  testWidgets('dismissible adds a close icon; it goes after its duration', (
    tester,
  ) async {
    await tester.pumpApp(
      host(
        (c) => c.showToast(
          'Saved',
          dismissible: true,
          duration: const Duration(seconds: 1),
        ),
      ),
    );
    await open(tester);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('an action needs both its label and its callback', (
    tester,
  ) async {
    await tester.pumpApp(host((c) => c.showToast('x', actionLabel: 'Undo')));
    await tester.tap(find.text('go'));

    expect(tester.takeException(), isA<AssertionError>());
  });

  group('semantics', () {
    testWidgets('a plain toast is a live region with its message', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(host((c) => c.showToast('Saved')));
      await open(tester);

      expect(
        tester.getSemantics(find.text('Saved')),
        isSemantics(label: 'Saved', isLiveRegion: true),
      );

      handle.dispose();
    });

    testWidgets('a toned toast is announced with its tone', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        host((c) => c.showToast('Payment failed', tone: FeedbackTone.error)),
      );
      await open(tester);

      expect(
        tester.getSemantics(find.text('Payment failed')),
        isSemantics(label: 'Error: Payment failed', isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('the tone word is French in French', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        host(
          (c) => c.showToast('Échec', tone: FeedbackTone.error),
          locale: const Locale('fr'),
        ),
      );
      await open(tester);

      expect(
        tester.getSemantics(find.text('Échec')),
        isSemantics(label: 'Erreur: Échec'),
      );
      handle.dispose();
    });

    testWidgets('the action is a button of at least 48 dp', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        host((c) => c.showToast('x', actionLabel: 'Undo', onAction: () {})),
      );
      await open(tester);

      expect(
        tester.getSemantics(find.text('Undo')),
        isSemantics(label: 'Undo', isButton: true),
      );
      expect(
        tester.getSize(find.byType(SnackBarAction)).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });
}
