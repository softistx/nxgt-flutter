import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/feedback.dart';

import '../support/host.dart';

void main() {
  Widget view(
    Future<List<String>> future, {
    Future<void> Function()? onRetry,
    Widget? empty,
  }) => themedHost(
    AsyncView<List<String>>(
      future: future,
      isEmpty: (items) => items.isEmpty,
      empty: empty,
      onRetry: onRetry,
      builder: (context, items) => Text(items.join(',')),
    ),
  );

  testWidgets('loading, then the content', (tester) async {
    final done = Completer<List<String>>();
    await tester.pumpApp(view(done.future));
    expect(find.byType(LoadingState), findsOneWidget);

    done.complete(['a', 'b']);
    await tester.pump();
    expect(find.byType(LoadingState), findsNothing);
    expect(find.text('a,b'), findsOneWidget);
  });

  testWidgets('shows the EmptyState for empty data, or the given one', (
    tester,
  ) async {
    await tester.pumpApp(view(Future.value(<String>[])));
    await tester.pump();
    expect(find.byType(EmptyState), findsOneWidget);

    await tester.pumpApp(
      view(Future.value(<String>[]), empty: const Text('No items')),
    );
    await tester.pump();
    expect(find.text('No items'), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('shows the ErrorState and retries through the handler', (
    tester,
  ) async {
    var retried = 0;
    final failing = Completer<List<String>>();
    await tester.pumpApp(view(failing.future, onRetry: () async => retried++));
    failing.completeError('boom');
    await tester.pump();

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('boom'), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(retried, 1);
  });

  testWidgets('reads a snapshot held by the caller', (tester) async {
    Widget fromSnapshot(AsyncSnapshot<int> snapshot) => themedHost(
      AsyncView<int>(
        snapshot: snapshot,
        builder: (context, value) => Text('value $value'),
      ),
    );

    await tester.pumpApp(fromSnapshot(const AsyncSnapshot.nothing()));
    expect(find.byType(LoadingState), findsOneWidget);

    await tester.pumpApp(
      fromSnapshot(const AsyncSnapshot.withData(ConnectionState.active, 3)),
    );
    expect(find.text('value 3'), findsOneWidget);

    await tester.pumpApp(
      fromSnapshot(const AsyncSnapshot.withError(ConnectionState.done, 'x')),
    );
    expect(find.byType(ErrorState), findsOneWidget);
  });

  testWidgets('a finished snapshot without data is empty for a non-null T', (
    tester,
  ) async {
    await tester.pumpApp(
      themedHost(
        AsyncView<int>(
          snapshot: const AsyncSnapshot<int>.nothing().inState(
            ConnectionState.done,
          ),
          builder: (context, value) => Text('value $value'),
        ),
      ),
    );

    expect(find.byType(EmptyState), findsOneWidget);
  });

  testWidgets('a nullable T is content once done', (tester) async {
    await tester.pumpApp(
      themedHost(
        AsyncView<void>(
          future: Future<void>.value(),
          builder: (context, _) => const Text('saved'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('saved'), findsOneWidget);
  });

  test('refuses both or neither of future and snapshot', () {
    expect(
      () => AsyncView<int>(builder: (context, v) => const SizedBox()),
      throwsAssertionError,
    );
    expect(
      () => AsyncView<int>(
        future: Future.value(1),
        snapshot: const AsyncSnapshot.nothing(),
        builder: (context, v) => const SizedBox(),
      ),
      throwsAssertionError,
    );
  });

  testWidgets('semantics: each state is a live region', (tester) async {
    final handle = tester.ensureSemantics();
    final done = Completer<List<String>>();
    await tester.pumpApp(view(done.future));
    expect(
      tester.getSemantics(find.text('Loading')),
      isSemantics(label: 'Loading', isLiveRegion: true),
    );

    done.complete(<String>[]);
    await tester.pump();
    expect(
      tester.getSemantics(find.text('Nothing here yet')),
      isSemantics(isLiveRegion: true, isHeader: true),
    );
    handle.dispose();
  });
}
