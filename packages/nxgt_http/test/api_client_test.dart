import 'package:dio/dio.dart';
import 'package:nxgt_http/nxgt_http.dart';
import 'package:test/test.dart';

import 'support/fake_adapter.dart';

class User {
  new(this.name);
  factory fromJson(Object? json) =>
      User((json! as Map<String, Object?>)['name']! as String);
  final String name;
}

ApiClient clientWith(
  FakeAdapter adapter, {
  Map<String, Object?>? headers,
  Duration? connectTimeout,
  Duration? receiveTimeout,
  List<Interceptor> interceptors = const [],
}) => ApiClient(
  baseUrl: Uri.parse('https://api.test/v1/'),
  adapter: adapter,
  headers: headers,
  connectTimeout: connectTimeout,
  receiveTimeout: receiveTimeout,
  interceptors: interceptors,
);

void main() {
  group('configuration', () {
    test('applies baseUrl, headers and timeouts to the Dio instance', () {
      final client = clientWith(
        FakeAdapter(),
        headers: {'x-app': 'demo', 'x-skip': null},
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 9),
      );

      expect(client.dio.options.baseUrl, 'https://api.test/v1/');
      expect(client.dio.options.headers['x-app'], 'demo');
      expect(client.dio.options.headers.containsKey('x-skip'), isFalse);
      expect(client.dio.options.connectTimeout, const Duration(seconds: 4));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 9));
    });

    test('installs the adapter and the user interceptors', () async {
      final adapter = FakeAdapter([FakeReply.json({})]);
      final seen = <String>[];
      final client = clientWith(
        adapter,
        interceptors: [
          InterceptorsWrapper(
            onRequest: (options, handler) {
              seen.add(options.path);
              handler.next(options);
            },
          ),
        ],
      );

      await client.get<Object?>('/ping');

      expect(seen, ['/ping']);
      expect(client.dio.httpClientAdapter, same(adapter));
    });

    test('wrap keeps the given Dio untouched', () async {
      final adapter = FakeAdapter([
        FakeReply.json({'name': 'Ada'}),
      ]);
      final dio = Dio(BaseOptions(baseUrl: 'https://wrapped.test'))
        ..httpClientAdapter = adapter;

      final client = ApiClient.wrap(dio);
      final user = await client.get('/me', decode: User.fromJson);

      expect(client.dio, same(dio));
      expect(user.name, 'Ada');
      expect(adapter.requests.single.uri.toString(), 'https://wrapped.test/me');
    });
  });

  group('requests', () {
    test('each verb sends the right method, query and body', () async {
      final adapter = FakeAdapter([FakeReply.json({})]);
      final client = clientWith(adapter);

      await client.get<Object?>('users', query: {'page': 2, 'q': null});
      await client.post<Object?>('users', data: {'a': 1});
      await client.put<Object?>('users/1', data: {'a': 2});
      await client.patch<Object?>('users/1', data: {'a': 3});
      await client.delete<Object?>('users/1');

      expect(adapter.requests.map((r) => r.method), [
        'GET',
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
      ]);
      expect(
        adapter.requests.first.uri.toString(),
        'https://api.test/v1/users?page=2',
      );
      expect(adapter.requests[1].data, {'a': 1});
      expect(adapter.requests[3].data, {'a': 3});
      expect(adapter.requests[4].uri.path, '/v1/users/1');
    });

    test('merges per-call options and forwards the cancel token', () async {
      final adapter = FakeAdapter([FakeReply.json({})]);
      final client = clientWith(adapter);
      final token = CancelToken();

      await client.get<Object?>(
        '/x',
        options: Options(headers: {'x-call': '1'}),
        cancelToken: token,
      );

      expect(adapter.requests.single.headers['x-call'], '1');
      expect(adapter.requests.single.cancelToken, same(token));
    });

    test('decode turns the JSON body into a value', () async {
      final adapter = FakeAdapter([
        FakeReply.json({'name': 'Ada'}),
        FakeReply.json([
          {'name': 'A'},
          {'name': 'B'},
        ]),
      ]);
      final client = clientWith(adapter);

      final user = await client.get('/u', decode: User.fromJson);
      final users = await client.get<List<User>>(
        '/us',
        decode: (json) => [for (final j in json! as List) User.fromJson(j)],
      );

      expect(user.name, 'Ada');
      expect(users.map((u) => u.name), ['A', 'B']);
    });

    test('without decode the body is returned as is', () async {
      final client = clientWith(
        FakeAdapter([
          FakeReply.json({'ok': true}),
        ]),
      );

      final body = await client.get<Map<String, Object?>>('/x');

      expect(body, {'ok': true});
    });

    test('an empty body is null for a nullable type', () async {
      final client = clientWith(
        FakeAdapter([FakeReply.json(null, status: 204)]),
      );

      final body = await client.delete<Object?>('/x');

      expect(body, anyOf(isNull, ''));
    });
  });

  group('errors are thrown as ApiError', () {
    test('a 4xx/5xx reply is a StatusError with its data', () async {
      final client = clientWith(
        FakeAdapter([
          FakeReply.json({'message': 'gone'}, status: 404),
        ]),
      );

      await expectLater(
        client.get<Object?>('/missing'),
        throwsA(
          isA<StatusError>()
              .having((e) => e.status, 'status', 404)
              .having((e) => e.data, 'data', {'message': 'gone'})
              .having((e) => e.method, 'method', 'GET')
              .having((e) => e.path, 'path', '/missing'),
        ),
      );
    });

    test('a timeout reply is a TimeoutError with its stage', () async {
      final client = clientWith(
        FakeAdapter([FakeReply.failure(DioExceptionType.receiveTimeout)]),
        receiveTimeout: const Duration(seconds: 5),
      );

      await expectLater(
        client.get<Object?>('/slow'),
        throwsA(
          isA<TimeoutError>()
              .having((e) => e.stage, 'stage', TimeoutStage.receive)
              .having((e) => e.timeout, 'timeout', const Duration(seconds: 5)),
        ),
      );
    });

    test('a connection failure is a NetworkError', () async {
      final client = clientWith(
        FakeAdapter([FakeReply.failure(DioExceptionType.connectionError)]),
      );

      await expectLater(
        client.post<Object?>('/x', data: {}),
        throwsA(isA<NetworkError>().having((e) => e.method, 'method', 'POST')),
      );
    });

    test('a cancelled call is a CancelledError, not a failure', () async {
      final adapter = FakeAdapter([FakeReply.json({})]);
      final client = clientWith(adapter);
      final token = CancelToken()..cancel('left screen');

      await expectLater(
        client.get<Object?>('/x', cancelToken: token),
        throwsA(
          isA<CancelledError>()
              .having((e) => e.reason, 'reason', 'left screen')
              .having((e) => e.isFailure, 'isFailure', isFalse),
        ),
      );
      expect(adapter.calls, 0);
    });

    test('a decode that throws is a DecodeError with the cause', () async {
      final client = clientWith(
        FakeAdapter([
          FakeReply.json({'nope': 1}),
        ]),
      );

      await expectLater(
        client.get('/u', decode: User.fromJson),
        throwsA(
          isA<DecodeError>()
              .having((e) => e.path, 'path', '/u')
              .having((e) => e.cause, 'cause', isA<TypeError>())
              .having((e) => e.stackTrace, 'stackTrace', isNotNull),
        ),
      );
    });

    test('a body of the wrong type without decode is a DecodeError', () async {
      final client = clientWith(
        FakeAdapter([
          FakeReply.json([1, 2]),
        ]),
      );

      await expectLater(
        client.get<Map<String, Object?>>('/x'),
        throwsA(isA<DecodeError>()),
      );
    });

    test('an error raised by an interceptor as ApiError is rethrown', () async {
      final client = clientWith(
        FakeAdapter([FakeReply.json({})]),
        interceptors: [
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.reject(
              DioException(
                requestOptions: options,
                error: const NetworkError(method: 'GET', path: '/x'),
              ),
            ),
          ),
        ],
      );

      await expectLater(
        client.get<Object?>('/x'),
        throwsA(isA<NetworkError>()),
      );
    });
  });
}
