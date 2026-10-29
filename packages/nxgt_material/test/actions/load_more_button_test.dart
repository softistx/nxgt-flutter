import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/actions.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('shows "Show more" and loads on press', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      host(LoadMoreButton(onPressed: () async => calls++)),
    );

    expect(find.text('Show more'), findsOneWidget);
    await tester.tap(find.byType(LoadMoreButton));
    await tester.pump();
    expect(calls, 1);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
    testWidgets('is at least 48 dp high on $platform', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await tester.pumpWidget(host(LoadMoreButton(onPressed: () async {})));
        expect(
          tester.getSize(find.byType(AsyncButton)).height,
          greaterThanOrEqualTo(48),
        );
        await tester.tap(find.byType(LoadMoreButton));
        await tester.pump();
        expect(
          tester.getSize(find.byType(AsyncButton)).height,
          greaterThanOrEqualTo(48),
        );
        await tester.pumpAndSettle();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('builds nothing once there is no more', (tester) async {
    await tester.pumpWidget(
      host(LoadMoreButton(hasMore: false, onPressed: () async {})),
    );

    expect(find.byType(AsyncButton), findsNothing);
  });

  testWidgets('takes a custom label', (tester) async {
    await tester.pumpWidget(
      host(LoadMoreButton(label: 'Older', onPressed: () async {})),
    );

    expect(find.text('Older'), findsOneWidget);
  });

  testWidgets('semantics: labelled button of at least 48 dp', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(LoadMoreButton(onPressed: () async {})));

    expect(find.bySemanticsLabel('Show more'), findsOneWidget);
    expect(
      tester.getSize(find.byType(LoadMoreButton)).height,
      greaterThanOrEqualTo(48),
    );
    handle.dispose();
  });
}
