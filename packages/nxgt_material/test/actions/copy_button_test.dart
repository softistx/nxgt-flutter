import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/actions.dart';

void main() {
  String? clipboard;

  setUp(() {
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
  });

  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('copies the value and shows a check mark, then resets', (
    tester,
  ) async {
    var copied = 0;
    await tester.pumpWidget(
      host(CopyButton(value: 'abc', onCopied: () => copied++)),
    );
    expect(find.byIcon(Icons.content_copy_outlined), findsOneWidget);

    await tester.tap(find.byType(CopyButton));
    await tester.pump();

    expect(clipboard, 'abc');
    expect(copied, 1);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.byIcon(Icons.content_copy_outlined), findsOneWidget);
  });

  testWidgets('a second copy restarts the timer', (tester) async {
    await tester.pumpWidget(host(const CopyButton(value: 'abc')));

    await tester.tap(find.byType(CopyButton));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byType(CopyButton));
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('disposing while copied leaves no pending timer', (tester) async {
    await tester.pumpWidget(host(const CopyButton(value: 'abc')));
    await tester.tap(find.byType(CopyButton));
    await tester.pump();

    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('tooltip reads Copy, Copied, or the override', (tester) async {
    await tester.pumpWidget(host(const CopyButton(value: 'abc')));
    expect(find.byTooltip('Copy'), findsOneWidget);

    await tester.tap(find.byType(CopyButton));
    await tester.pump();
    expect(find.byTooltip('Copied'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(
      host(const CopyButton(value: 'a', tooltip: 'Copy id')),
    );
    expect(find.byTooltip('Copy id'), findsOneWidget);
  });

  testWidgets('a clipboard failure is reported and shows no check mark', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            throw PlatformException(code: 'denied');
          }
          return null;
        });
    var copied = 0;
    await tester.pumpWidget(
      host(CopyButton(value: 'abc', onCopied: () => copied++)),
    );

    await tester.tap(find.byType(CopyButton));
    await tester.pump();

    expect(tester.takeException(), isA<PlatformException>());
    expect(copied, 0);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  group('semantics', () {
    testWidgets('is a labelled button in a live region, 48 dp wide', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const CopyButton(value: 'abc')));

      expect(
        tester.getSemantics(find.byType(IconButton)),
        matchesSemantics(
          label: 'Copy',
          isButton: true,
          isLiveRegion: true,
          isEnabled: true,
          isFocusable: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      final size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));

      await tester.tap(find.byType(CopyButton));
      await tester.pump();
      expect(find.bySemanticsLabel('Copied'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      handle.dispose();
    });
  });
}
