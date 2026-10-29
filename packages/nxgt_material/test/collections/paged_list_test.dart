import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/actions.dart';
import 'package:nxgt_material/collections.dart';
import 'package:nxgt_material/feedback.dart';

import '../support/host.dart';

Widget _row(BuildContext context, String item, int index) =>
    SizedBox(height: 56, child: Text(item));

List<String> _items(int count, [int from = 0]) => [
  for (var i = from; i < from + count; i++) 'Item $i',
];

/// A list whose items the test grows through [load].
class _Harness extends StatefulWidget {
  const new({
    required this.load,
    this.initial = 3,
    this.mode = LoadMoreMode.button,
    this.hasMore = true,
    this.onRefresh,
    this.controller,
    this.separated = false,
  });

  final Future<List<String>> Function(int loaded) load;
  final int initial;
  final LoadMoreMode mode;
  final bool hasMore;
  final Future<void> Function()? onRefresh;
  final ScrollController? controller;
  final bool separated;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late List<String> items = _items(widget.initial);
  int calls = 0;

  @override
  Widget build(BuildContext context) => PagedList<String>(
    items: items,
    itemBuilder: _row,
    hasMore: widget.hasMore,
    loadMoreMode: widget.mode,
    controller: widget.controller,
    onRefresh: widget.onRefresh,
    separatorBuilder: widget.separated
        ? (context, index) => Text('sep $index')
        : null,
    onLoadMore: () async {
      calls++;
      final more = await widget.load(items.length);
      setState(() => items = [...items, ...more]);
    },
  );
}

void main() {
  final showMore = find.text('Show more');

  group('first load', () {
    testWidgets('loading shows the LoadingState', (tester) async {
      await tester.pumpApp(
        themedHost(
          const PagedList<String>(items: [], itemBuilder: _row, loading: true),
        ),
      );
      expect(find.byType(LoadingState), findsOneWidget);
    });

    testWidgets('error shows the ErrorState and retries', (tester) async {
      var retries = 0;
      await tester.pumpApp(
        themedHost(
          PagedList<String>(
            items: const [],
            itemBuilder: _row,
            error: Exception('boom'),
            onRetry: () async => retries++,
          ),
        ),
      );
      expect(find.byType(ErrorState), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retries, 1);
    });

    testWidgets('errorBuilder builds the first-load failure', (tester) async {
      await tester.pumpApp(
        themedHost(
          PagedList<String>(
            items: const [],
            itemBuilder: _row,
            error: 'nope',
            errorBuilder: (context, error) => Text('custom $error'),
          ),
        ),
      );
      expect(find.text('custom nope'), findsOneWidget);
      expect(find.byType(ErrorState), findsNothing);
    });

    testWidgets('no item shows the EmptyState or the given one', (
      tester,
    ) async {
      await tester.pumpApp(
        themedHost(const PagedList<String>(items: [], itemBuilder: _row)),
      );
      expect(find.byType(EmptyState), findsOneWidget);
      await tester.pumpApp(
        themedHost(
          const PagedList<String>(
            items: [],
            itemBuilder: _row,
            empty: Text('No patients'),
          ),
        ),
      );
      expect(find.text('No patients'), findsOneWidget);
    });
  });

  group('items', () {
    testWidgets('render, with separators between but not after', (
      tester,
    ) async {
      await tester.pumpApp(
        themedHost(
          _Harness(load: (_) async => [], hasMore: false, separated: true),
        ),
      );
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('sep 0'), findsOneWidget);
      expect(find.text('sep 1'), findsOneWidget);
      expect(find.text('sep 2'), findsNothing);
    });

    testWidgets('hasMore false shows no button and loads nothing', (
      tester,
    ) async {
      await tester.pumpApp(
        themedHost(_Harness(load: (_) async => [], hasMore: false)),
      );
      expect(showMore, findsNothing);
    });

    testWidgets('hasMore without onLoadMore asserts', (tester) async {
      expect(
        () => PagedList<String>(
          items: const [],
          itemBuilder: _row,
          hasMore: true,
        ),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'PagedList.hasMore is true but onLoadMore is null.',
          ),
        ),
      );
    });
  });

  group('button mode', () {
    testWidgets('loads more and announces the page', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        themedHost(_Harness(load: (loaded) async => _items(3, loaded))),
      );
      await tester.tap(showMore);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Item 5', skipOffstage: false), findsOneWidget);
      expect(find.bySemanticsLabel('3 more loaded'), findsOneWidget);
      final node = tester.getSemantics(find.bySemanticsLabel('3 more loaded'));
      // The role sits on the container around the live-region node.
      expect(node.parent!.getSemanticsData().role, SemanticsRole.status);
      // The announcement goes away, so the next page is announced again.
      await tester.pump(const Duration(seconds: 3));
      expect(find.bySemanticsLabel('3 more loaded'), findsNothing);
      handle.dispose();
    });

    testWidgets('announces in French, and a single item', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        themedHost(
          _Harness(load: (loaded) async => _items(1, loaded)),
          locale: const Locale('fr'),
        ),
      );
      await tester.tap(find.text('Afficher plus'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.bySemanticsLabel('1 élément de plus chargé'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      handle.dispose();
    });

    testWidgets('an empty page announces nothing', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(themedHost(_Harness(load: (_) async => [])));
      await tester.tap(showMore);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp('more loaded')), findsNothing);
      handle.dispose();
    });

    testWidgets('a throwing onLoadMore shows the inline error, then retries', (
      tester,
    ) async {
      var fail = true;
      await tester.pumpApp(
        themedHost(
          _Harness(
            load: (loaded) async {
              if (fail) throw StateError('network');
              return _items(2, loaded);
            },
          ),
        ),
      );
      await tester.tap(showMore);
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isA<StateError>());
      expect(find.byType(ErrorState, skipOffstage: false), findsOneWidget);
      expect(showMore, findsNothing);

      fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.byType(ErrorState, skipOffstage: false), findsNothing);
      expect(find.text('Item 4', skipOffstage: false), findsOneWidget);
      expect(showMore, findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('a press while loading does not call again', (tester) async {
      final completer = Completer<List<String>>();
      await tester.pumpApp(themedHost(_Harness(load: (_) => completer.future)));
      final state = tester.state<_HarnessState>(find.byType(_Harness));
      await tester.tap(showMore);
      await tester.pump();
      await tester.tap(showMore, warnIfMissed: false);
      await tester.pump();
      expect(state.calls, 1);
      completer.complete([]);
      await tester.pump();
    });
  });

  group('scroll mode', () {
    Future<void> scrollToEnd(WidgetTester tester) async {
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();
    }

    testWidgets('triggers once near the end and not while running', (
      tester,
    ) async {
      final completer = Completer<List<String>>();
      await tester.pumpApp(
        themedHost(
          _Harness(
            initial: 30,
            mode: LoadMoreMode.onScroll,
            load: (_) => completer.future,
          ),
        ),
      );
      final state = tester.state<_HarnessState>(find.byType(_Harness));
      expect(state.calls, 0);
      expect(showMore, findsNothing);

      await scrollToEnd(tester);
      expect(state.calls, 1);
      expect(find.byType(LoadingState, skipOffstage: false), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pump();
      expect(state.calls, 1);

      completer.complete(_items(40, 30));
      await tester.pump();
      await tester.pump();
      expect(state.calls, 1);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('fills a viewport the first page does not fill', (
      tester,
    ) async {
      var pages = 0;
      await tester.pumpApp(
        themedHost(
          _Harness(
            initial: 2,
            mode: LoadMoreMode.onScroll,
            load: (loaded) async => pages++ < 1 ? _items(40, loaded) : [],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(pages, 1);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('a load that adds nothing is not repeated', (tester) async {
      await tester.pumpApp(
        themedHost(
          _Harness(
            initial: 2,
            mode: LoadMoreMode.onScroll,
            load: (_) async => [],
          ),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
      expect(tester.state<_HarnessState>(find.byType(_Harness)).calls, 1);
    });

    testWidgets('a throwing onLoadMore shows retry and stops auto-loading', (
      tester,
    ) async {
      var fail = true;
      await tester.pumpApp(
        themedHost(
          _Harness(
            initial: 30,
            mode: LoadMoreMode.onScroll,
            load: (loaded) async {
              if (fail) throw StateError('network');
              return _items(40, loaded);
            },
          ),
        ),
      );
      final state = tester.state<_HarnessState>(find.byType(_Harness));
      await scrollToEnd(tester);
      await tester.pump();
      expect(tester.takeException(), isA<StateError>());
      expect(find.byType(ErrorState, skipOffstage: false), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(state.calls, 1);

      fail = false;
      await tester.ensureVisible(find.text('Retry'));
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(state.calls, 2);
      expect(find.byType(ErrorState, skipOffstage: false), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('hasMore false does not trigger', (tester) async {
      await tester.pumpApp(
        themedHost(
          _Harness(
            initial: 30,
            hasMore: false,
            mode: LoadMoreMode.onScroll,
            load: (_) async => [],
          ),
        ),
      );
      await scrollToEnd(tester);
      expect(tester.state<_HarnessState>(find.byType(_Harness)).calls, 0);
    });
  });

  group('caller-driven state', () {
    testWidgets('error with items shows the inline error and retry', (
      tester,
    ) async {
      var retries = 0;
      await tester.pumpApp(
        themedHost(
          PagedList<String>(
            items: _items(2),
            itemBuilder: _row,
            hasMore: true,
            onLoadMore: () async {},
            loadMoreMode: LoadMoreMode.onScroll,
            error: 'x',
            onRetry: () async => retries++,
          ),
        ),
      );
      expect(find.text('Item 1'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retries, 1);
    });

    testWidgets('loading with items shows a LoadingState at the end', (
      tester,
    ) async {
      await tester.pumpApp(
        themedHost(
          PagedList<String>(items: _items(2), itemBuilder: _row, loading: true),
        ),
      );
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.byType(LoadingState), findsOneWidget);
    });
  });

  group('refresh', () {
    testWidgets('pulling down calls onRefresh', (tester) async {
      var refreshes = 0;
      await tester.pumpApp(
        themedHost(
          _Harness(
            hasMore: false,
            load: (_) async => [],
            onRefresh: () async => refreshes++,
          ),
        ),
      );
      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(refreshes, 1);
    });

    testWidgets('no onRefresh, no RefreshIndicator', (tester) async {
      await tester.pumpApp(
        themedHost(_Harness(hasMore: false, load: (_) async => [])),
      );
      expect(find.byType(RefreshIndicator), findsNothing);
    });
  });

  group('controller', () {
    testWidgets('an external controller scrolls the list and survives', (
      tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpApp(
        themedHost(
          _Harness(
            initial: 40,
            hasMore: false,
            load: (_) async => [],
            controller: controller,
          ),
        ),
      );
      controller.jumpTo(300);
      await tester.pump();
      expect(controller.offset, 300);
      await tester.pumpWidget(const SizedBox());
      // Still usable: the list never disposed it.
      expect(controller.dispose, returnsNormally);
    });

    testWidgets('an owned controller is created and disposed', (tester) async {
      await tester.pumpApp(
        themedHost(
          _Harness(initial: 40, hasMore: false, load: (_) async => []),
        ),
      );
      final list = tester.widget<ListView>(find.byType(ListView));
      expect(list.controller, isNotNull);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });

  group('layout', () {
    testWidgets('mirrors in RTL and keeps working at text scale 2', (
      tester,
    ) async {
      await tester.pumpApp(
        themedHost(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: _Harness(load: (_) async => []),
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(showMore, findsOneWidget);
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
      testWidgets('the Show more button is 48 dp on $platform', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await tester.pumpApp(themedHost(_Harness(load: (_) async => [])));
          final size = tester.getSize(find.byType(AsyncButton));
          expect(size.height, greaterThanOrEqualTo(48));
          expect(size.width, greaterThanOrEqualTo(48));
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }

    testWidgets('fits a Scaffold body of constrained height', (tester) async {
      await tester.pumpApp(
        themedHost(
          SizedBox(
            height: 200,
            child: _Harness(initial: 20, load: (_) async => []),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PagedList<String>)).height, 200);
    });
  });
}
