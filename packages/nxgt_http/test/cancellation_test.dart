import 'package:dio/dio.dart';
import 'package:nxgt_http/nxgt_http.dart';
import 'package:test/test.dart';

import 'support/fake_adapter.dart';

const _slow = Duration(milliseconds: 40);

FakeReply _ok([Duration delay = _slow]) =>
    FakeReply.json({'ok': 1}, delay: delay);

ApiClient _client(
  FakeAdapter adapter, {
  RetryOptions? retry,
  AuthOptions? auth,
}) => ApiClient(
  baseUrl: Uri.parse('https://api.test/v1/'),
  adapter: adapter,
  retry: retry,
  auth: auth,
);

Matcher _cancelled([Object? reason]) => throwsA(
  isA<CancelledError>()
      .having((e) => e.isFailure, 'isFailure', isFalse)
      .having((e) => e.reason, 'reason', reason ?? anything),
);

void main() {
  group('group', () {
    test('cancel stops every call of the group at once', () async {
      final client = _client(FakeAdapter([_ok()]));
      final screen = client.group();

      final a = screen.get<Object?>('/a');
      final b = screen.post<Object?>('/b');
      screen.cancel('left screen');

      await expectLater(a, _cancelled('left screen'));
      await expectLater(b, _cancelled('left screen'));
    });

    test('shares the Dio of its parent', () {
      final client = _client(FakeAdapter());
      expect(client.group().dio, same(client.dio));
    });

    test('does not touch the parent or a sibling', () async {
      final client = _client(FakeAdapter([_ok()]));
      final one = client.group();
      final two = client.group();

      final fromParent = client.get<Object?>('/p');
      final fromOne = one.get<Object?>('/1');
      final fromTwo = two.get<Object?>('/2');
      one.cancel();

      await expectLater(fromOne, _cancelled());
      expect(await fromParent, isNotNull);
      expect(await fromTwo, isNotNull);
    });

    test('cancelling the parent cancels its groups too', () async {
      final client = _client(FakeAdapter([_ok()]));
      final nested = client.group().group();
      final own = client.get<Object?>('/p');
      final deep = nested.get<Object?>('/deep');

      client.cancel('shutdown');

      await expectLater(own, _cancelled('shutdown'));
      await expectLater(deep, _cancelled('shutdown'));
    });

    test('stays usable after cancel', () async {
      final client = _client(FakeAdapter([_ok(Duration.zero)]));
      final screen = client.group()..cancel();

      expect(await screen.get<Object?>('/x'), isNotNull);
    });

    test('cancel with nothing in flight is a no-op', () {
      _client(FakeAdapter()).group().cancel('nothing');
    });

    test('releases the tokens of completed calls', () async {
      final client = _client(FakeAdapter([_ok(Duration.zero)]));
      final screen = client.group();

      await screen.get<Object?>('/x', latest: 'k');
      await expectLater(
        _client(FakeAdapter([FakeReply.json({}, status: 500)]))
            .group()
            .get<Object?>('/y', latest: 'k'),
        throwsA(isA<StatusError>()),
      );
      // A later cancel has nothing left to cancel: a held token would have
      // been cancelled, and a new call is unaffected either way.
      screen.cancel('late');
      client.cancel('late');
      expect(await screen.get<Object?>('/z'), isNotNull);
    });
  });

  group('latest', () {
    test('a new call with the same key cancels the previous one', () async {
      final adapter = FakeAdapter([_ok(), _ok(Duration.zero)]);
      final client = _client(adapter);

      final first = client.get<Object?>(
        '/search',
        query: {'q': 'a'},
        latest: 'search',
      );
      final second = client.get<Object?>(
        '/search',
        query: {'q': 'ab'},
        latest: 'search',
      );

      await expectLater(first, _cancelled());
      expect(await second, isNotNull);
    });

    test('different keys and calls without a key do not interfere', () async {
      final client = _client(FakeAdapter([_ok()]));

      final results = await Future.wait([
        client.get<Object?>('/a', latest: 'a'),
        client.get<Object?>('/b', latest: 'b'),
        client.get<Object?>('/c'),
      ]);

      expect(results, hasLength(3));
    });

    test('keys are per client: a sibling group keeps its call', () async {
      final client = _client(FakeAdapter([_ok()]));
      final one = client.group();
      final two = client.group();

      final a = one.get<Object?>('/s', latest: 'search');
      final b = two.get<Object?>('/s', latest: 'search');

      expect(await a, isNotNull);
      expect(await b, isNotNull);
    });

    test('a finished call is not cancelled by the next one', () async {
      final client = _client(FakeAdapter([_ok(Duration.zero)]));

      expect(await client.get<Object?>('/s', latest: 'k'), isNotNull);
      expect(await client.get<Object?>('/s', latest: 'k'), isNotNull);
    });

    test('works on post, put, patch and delete', () async {
      final client = _client(FakeAdapter([_ok()]));
      final calls = <Future<Object?> Function()>[
        () => client.post<Object?>('/x', latest: 'k'),
        () => client.put<Object?>('/x', latest: 'k'),
        () => client.patch<Object?>('/x', latest: 'k'),
        () => client.delete<Object?>('/x', latest: 'k'),
      ];
      final started = [for (final call in calls) call()];

      for (final f in started.take(3)) {
        await expectLater(f, _cancelled());
      }
      expect(await started.last, isNotNull);
    });
  });

  group('cancel token and isCancelled', () {
    test(
      "the caller's own token still cancels the call, with its reason",
      () async {
        final client = _client(FakeAdapter([_ok()]));
        final token = CancelToken();

        final call = client.get<Object?>('/x', cancelToken: token);
        token.cancel('mine');

        await expectLater(call, _cancelled('mine'));
      },
    );

    test(
      'a finished call is not touched when its caller token cancels',
      () async {
        final adapter = FakeAdapter([_ok(Duration.zero)]);
        final client = _client(adapter);
        final token = CancelToken();

        await client.get<Object?>('/x', cancelToken: token);
        token.cancel('late');
        await Future<void>.delayed(Duration.zero);

        expect(adapter.requests.single.cancelToken!.isCancelled, isFalse);
      },
    );

    test('an already cancelled caller token cancels at once', () async {
      final adapter = FakeAdapter([_ok()]);
      final client = _client(adapter);

      await expectLater(
        client.get<Object?>('/x', cancelToken: CancelToken()..cancel('early')),
        _cancelled('early'),
      );
      expect(adapter.calls, 0);
    });

    test('isCancelled recognises both error shapes and nothing else', () async {
      final client = _client(FakeAdapter([_ok()]));
      final call = client.get<Object?>('/x');
      client.cancel();
      Object? caught;
      try {
        await call;
      } on Object catch (e) {
        caught = e;
      }

      expect(isCancelled(caught!), isTrue);
      expect(
        isCancelled(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.cancel,
          ),
        ),
        isTrue,
      );
      expect(isCancelled(StateError('x')), isFalse);
      expect(
        isCancelled(const NetworkError(method: 'GET', path: '/x')),
        isFalse,
      );
    });
  });

  group('after a cancel', () {
    test('nothing is retried', () async {
      final adapter = FakeAdapter([
        FakeReply.failure(DioExceptionType.connectionError, delay: _slow),
      ]);
      final client = _client(
        adapter,
        retry: RetryOptions(delay: (_) => const Duration(milliseconds: 20)),
      );

      final call = client.get<Object?>('/x');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      client.cancel('stop');

      await expectLater(call, _cancelled());
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(adapter.calls, 1);
    });

    test('nothing is refreshed or replayed', () async {
      final adapter = FakeAdapter([
        FakeReply.json({}, status: 401, delay: _slow),
      ]);
      var refreshed = 0;
      final client = _client(
        adapter,
        auth: AuthOptions(token: () => 'old', refresh: () async => refreshed++),
      );

      final call = client.get<Object?>('/x');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      client.cancel('stop');

      await expectLater(call, _cancelled());
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(refreshed, 0);
      expect(adapter.calls, 1);
    });
  });
}
