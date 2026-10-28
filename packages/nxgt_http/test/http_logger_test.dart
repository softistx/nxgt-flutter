import 'package:dio/dio.dart';
import 'package:nxgt_http/nxgt_http.dart';
import 'package:test/test.dart';

import 'support/fake_adapter.dart';

void main() {
  late List<HttpLogRecord> records;

  ApiClient clientWith(
    FakeAdapter adapter, {
    HttpLogger? logger,
    RetryOptions? retry,
  }) => ApiClient(
    baseUrl: Uri.parse('https://api.test/v1/'),
    adapter: adapter,
    retry: retry,
    logger: logger ?? HttpLogger(sink: records.add),
  );

  setUp(() => records = []);

  test('records method, url, status and duration', () async {
    final client = clientWith(
      FakeAdapter([
        FakeReply.json({'ok': 1}, delay: const Duration(milliseconds: 30)),
      ]),
    );

    await client.get<Object?>('/things', query: {'page': 2});

    final record = records.single;
    expect(record.method, 'GET');
    expect(record.url.toString(), 'https://api.test/v1/things?page=2');
    expect(record.status, 200);
    expect(record.errorType, isNull);
    expect(record.isError, isFalse);
    expect(
      record.duration,
      greaterThanOrEqualTo(const Duration(milliseconds: 25)),
    );
    expect(record.toString(), startsWith('GET https://api.test/v1/things'));
  });

  test('a non-2xx answer is a badResponse record with its status', () async {
    final client = clientWith(FakeAdapter([FakeReply.json({}, status: 404)]));

    await expectLater(client.get<Object?>('/x'), throwsA(isA<StatusError>()));

    expect(records.single.status, 404);
    expect(records.single.errorType, DioExceptionType.badResponse);
    expect(records.single.isError, isTrue);
  });

  test('a transport failure records its error type and no status', () async {
    final client = clientWith(
      FakeAdapter([FakeReply.failure(DioExceptionType.connectionError)]),
    );

    await expectLater(client.get<Object?>('/x'), throwsA(isA<NetworkError>()));

    expect(records.single.status, isNull);
    expect(records.single.errorType, DioExceptionType.connectionError);
  });

  test('redacts the default headers, case-insensitively, both ways', () async {
    final client = clientWith(
      FakeAdapter([
        FakeReply.json(
          {},
          headers: {
            'Set-Cookie': ['a=1', 'b=2'],
            'x-shown': ['yes'],
          },
        ),
      ]),
    );

    await client.get<Object?>(
      '/x',
      options: Options(
        headers: {
          'Authorization': 'Bearer secret',
          'COOKIE': 'sid=1',
          'x-a': 'b',
        },
      ),
    );

    final record = records.single;
    expect(record.requestHeaders['Authorization'], HttpLogger.redacted);
    expect(record.requestHeaders['COOKIE'], HttpLogger.redacted);
    expect(record.requestHeaders['x-a'], 'b');
    expect(
      record.responseHeaders.entries
          .singleWhere((e) => e.key.toLowerCase() == 'set-cookie')
          .value,
      HttpLogger.redacted,
    );
    expect(record.responseHeaders['x-shown'], 'yes');
    expect(record.requestHeaders.toString(), isNot(contains('secret')));
  });

  test('redact replaces the default set', () async {
    final client = clientWith(
      FakeAdapter([FakeReply.json({})]),
      logger: HttpLogger(sink: records.add, redact: {'X-Api-Key'}),
    );

    await client.get<Object?>(
      '/x',
      options: Options(headers: {'x-api-key': 'k', 'authorization': 'visible'}),
    );

    expect(records.single.requestHeaders['x-api-key'], HttpLogger.redacted);
    expect(records.single.requestHeaders['authorization'], 'visible');
  });

  test('bodies are left out by default', () async {
    final client = clientWith(
      FakeAdapter([
        FakeReply.json({'a': 1}),
      ]),
    );

    await client.post<Object?>('/x', data: {'pw': 'secret'});

    expect(records.single.requestBody, isNull);
    expect(records.single.responseBody, isNull);
  });

  test('bodies: true puts both bodies in the record', () async {
    final client = clientWith(
      FakeAdapter([
        FakeReply.json({'a': 1}),
      ]),
      logger: HttpLogger(sink: records.add, bodies: true),
    );

    await client.post<Object?>('/x', data: {'q': 1});

    expect(records.single.requestBody, {'q': 1});
    expect(records.single.responseBody, {'a': 1});
  });

  test('the record is immutable', () async {
    final client = clientWith(FakeAdapter([FakeReply.json({})]));
    await client.get<Object?>('/x');

    expect(
      () => records.single.requestHeaders['a'] = 'b',
      throwsUnsupportedError,
    );
  });

  test('a throwing sink does not break the call', () async {
    final client = clientWith(
      FakeAdapter([
        FakeReply.json({'a': 1}),
      ]),
      logger: HttpLogger(sink: (_) => throw StateError('boom')),
    );

    expect(await client.get<Object?>('/x'), isNotNull);
  });

  test('works on a plain Dio', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = FakeAdapter([FakeReply.json({})])
      ..interceptors.add(HttpLogger(sink: records.add));

    await dio.get<Object?>('/plain');

    expect(records.single.url.path, '/plain');
  });

  test('a retried request is logged once per attempt', () async {
    final client = clientWith(
      FakeAdapter([FakeReply.json({}, status: 503), FakeReply.json({})]),
      retry: RetryOptions(delay: (_) => Duration.zero),
    );

    await client.get<Object?>('/x');

    expect(records.map((r) => r.status), [503, 200]);
  });

  test(
    'the logger runs before auth: it sees the header the caller set',
    () async {
      final adapter = FakeAdapter([FakeReply.json({})]);
      final client = ApiClient(
        baseUrl: Uri.parse('https://api.test/v1/'),
        adapter: adapter,
        logger: HttpLogger(sink: records.add),
        auth: AuthOptions(token: () => 'tok'),
      );

      await client.get<Object?>('/x');

      expect(adapter.requests.single.headers['authorization'], 'Bearer tok');
      expect(
        records.single.requestHeaders['authorization'],
        HttpLogger.redacted,
      );
    },
  );
}
