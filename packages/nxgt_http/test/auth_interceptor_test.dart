import 'package:dio/dio.dart';
import 'package:nxgt_http/nxgt_http.dart';
import 'package:test/test.dart';

import 'support/fake_adapter.dart';

FakeReply ok() => FakeReply.json({'ok': true});
FakeReply unauthorized() => FakeReply.json({'error': 'no'}, status: 401);

class Session {
  String? token = 'old';
  int refreshes = 0;
  Exception? refreshError;
  bool rotate = true;

  AuthOptions get options => AuthOptions(
    token: () => token,
    refresh: () async {
      refreshes++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (refreshError != null) throw refreshError!;
      if (rotate) token = 'new$refreshes';
    },
  );
}

ApiClient clientFor(FakeAdapter adapter, AuthOptions auth) => ApiClient(
  baseUrl: Uri.parse('https://api.test/'),
  adapter: adapter,
  auth: auth,
);

String? authHeader(RequestOptions r) => r.headers['authorization'] as String?;

void main() {
  test('sends the token with its scheme and nothing when signed out', () async {
    final session = Session();
    final adapter = FakeAdapter([ok()]);
    final client = clientFor(adapter, session.options);
    await client.get<Object?>('/a');
    session.token = null;
    await client.get<Object?>('/b');

    expect(authHeader(adapter.requests[0]), 'Bearer old');
    expect(authHeader(adapter.requests[1]), isNull);
  });

  test('keeps an Authorization header the caller set', () async {
    final adapter = FakeAdapter([ok()]);
    await clientFor(adapter, Session().options).get<Object?>(
      '/a',
      options: Options(headers: {'Authorization': 'Basic x'}),
    );
    expect(adapter.requests.single.headers['Authorization'], 'Basic x');
  });

  test('a 401 on a caller-set Authorization header is not refreshed', () async {
    final session = Session();
    final adapter = FakeAdapter([unauthorized()]);

    await expectLater(
      clientFor(adapter, session.options).get<Object?>(
        '/a',
        options: Options(headers: {'Authorization': 'Basic x'}),
      ),
      throwsA(isA<StatusError>()),
    );
    expect(session.refreshes, 0);
    expect(adapter.calls, 1);
  });

  test('a 401 refreshes once and replays with the new token', () async {
    final session = Session();
    final adapter = FakeAdapter([unauthorized(), ok()]);
    final result = await clientFor(
      adapter,
      session.options,
    ).get<Map<String, Object?>>('/me');

    expect(result, {'ok': true});
    expect(session.refreshes, 1);
    expect(adapter.calls, 2);
    expect(authHeader(adapter.requests[1]), 'Bearer new1');
  });

  test('concurrent 401s share one refresh', () async {
    final session = Session();
    final adapter = FakeAdapter([
      unauthorized(),
      unauthorized(),
      unauthorized(),
      ok(),
    ]);
    final client = clientFor(adapter, session.options);

    final results = await Future.wait([
      client.get<Object?>('/a'),
      client.get<Object?>('/b'),
      client.get<Object?>('/c'),
    ]);

    expect(results, hasLength(3));
    expect(session.refreshes, 1);
    expect(adapter.calls, 6);
    expect(
      adapter.requests.skip(3).map(authHeader),
      everyElement('Bearer new1'),
    );
  });

  test('a late 401 for a stale token replays without refreshing', () async {
    final session = Session();
    final adapter = FakeAdapter([
      FakeReply.json({}, status: 401, delay: const Duration(milliseconds: 80)),
      unauthorized(),
      ok(),
    ]);
    final client = clientFor(adapter, session.options);
    final slow = client.get<Object?>('/slow');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final fast = client.get<Object?>('/fast');
    await Future.wait([slow, fast]);

    expect(session.refreshes, 1);
  });

  test('a failed refresh surfaces as the 401 StatusError', () async {
    final session = Session()..refreshError = const FormatException('revoked');
    final adapter = FakeAdapter([unauthorized()]);

    await expectLater(
      clientFor(adapter, session.options).get<Object?>('/me'),
      throwsA(
        isA<StatusError>()
            .having((e) => e.status, 'status', 401)
            .having(
              (e) => (e.cause! as DioException).error,
              'refresh error',
              isA<FormatException>(),
            ),
      ),
    );
    expect(adapter.calls, 1);
  });

  test('concurrent callers all see a failed refresh, once', () async {
    final session = Session()..refreshError = const FormatException('revoked');
    final adapter = FakeAdapter([unauthorized()]);
    final client = clientFor(adapter, session.options);

    final outcomes = await Future.wait([
      for (final p in ['/a', '/b'])
        client
            .get<Object?>(p)
            .then<Object?>((v) => v, onError: (Object e) => e),
    ]);

    expect(outcomes, everyElement(isA<StatusError>()));
    expect(session.refreshes, 1);
  });

  test('a token that does not change leaves the 401', () async {
    final session = Session()..rotate = false;
    final adapter = FakeAdapter([unauthorized()]);

    await expectLater(
      clientFor(adapter, session.options).get<Object?>('/me'),
      throwsA(isA<StatusError>().having((e) => e.status, 'status', 401)),
    );
    expect(adapter.calls, 1);
  });

  test('a 401 on the replay is final: no loop', () async {
    final session = Session();
    final adapter = FakeAdapter([unauthorized()]);

    await expectLater(
      clientFor(adapter, session.options).get<Object?>('/me'),
      throwsA(isA<StatusError>().having((e) => e.status, 'status', 401)),
    );
    expect(session.refreshes, 1);
    expect(adapter.calls, 2);
  });

  test('without refresh a 401 is returned as is', () async {
    final adapter = FakeAdapter([unauthorized()]);
    final client = clientFor(adapter, AuthOptions(token: () => 'x'));

    await expectLater(client.get<Object?>('/me'), throwsA(isA<StatusError>()));
    expect(adapter.calls, 1);
  });

  test('other statuses do not refresh', () async {
    final session = Session();
    final adapter = FakeAdapter([FakeReply.json({}, status: 500)]);

    await expectLater(
      clientFor(adapter, session.options).get<Object?>('/me'),
      throwsA(isA<StatusError>()),
    );
    expect(session.refreshes, 0);
  });

  test('a replayed FormData body is cloned', () async {
    final session = Session();
    final adapter = FakeAdapter([unauthorized(), ok()]);
    final form = FormData.fromMap({'a': '1'});

    await clientFor(adapter, session.options).post<Object?>('/up', data: form);

    expect(adapter.calls, 2);
    expect(adapter.requests[1].data, isA<FormData>());
    expect(adapter.requests[1].data, isNot(same(form)));
  });

  test('works on a plain Dio', () async {
    final session = Session();
    final adapter = FakeAdapter([unauthorized(), ok()]);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(session.options, dio));

    final response = await dio.get<Object?>('/me');

    expect(response.statusCode, 200);
    expect(session.refreshes, 1);
  });

  test(
    'a 401 while signed out runs refresh and replays once restored',
    () async {
      final session = Session()..token = null;
      final adapter = FakeAdapter([unauthorized(), ok()]);
      final client = ApiClient(
        baseUrl: Uri.parse('https://api.test/'),
        adapter: adapter,
        auth: AuthOptions(
          token: () => session.token,
          refresh: () async {
            session.refreshes++;
            session.token = 'restored';
          },
        ),
      );

      await client.get<Object?>('/me');

      expect(authHeader(adapter.requests[0]), isNull);
      expect(session.refreshes, 1);
      expect(authHeader(adapter.requests[1]), 'Bearer restored');
    },
  );

  test('a signed-out 401 is thrown when refresh does not restore it', () async {
    final session = Session()
      ..token = null
      ..rotate = false;
    final adapter = FakeAdapter([unauthorized()]);

    await expectLater(
      clientFor(adapter, session.options).get<Object?>('/me'),
      throwsA(isA<StatusError>().having((e) => e.status, 'status', 401)),
    );
    expect(session.refreshes, 1);
    expect(adapter.calls, 1);
  });

  test(
    'a token callback that throws is a NetworkError with the cause',
    () async {
      final adapter = FakeAdapter([ok()]);
      final client = clientFor(
        adapter,
        AuthOptions(token: () => throw StateError('keychain locked')),
      );

      await expectLater(
        client.get<Object?>('/me'),
        throwsA(
          isA<NetworkError>().having(
            (e) => e.cause,
            'cause',
            isA<StateError>(),
          ),
        ),
      );
      expect(adapter.calls, 0);
    },
  );
}
