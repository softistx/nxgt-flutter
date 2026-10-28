import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:nxgt_http/nxgt_http.dart';
import 'package:test/test.dart';

import 'support/fake_adapter.dart';

FakeReply ok() => FakeReply.json({'ok': true});
FakeReply status(int code, {Map<String, List<String>> headers = const {}}) =>
    FakeReply.json({'e': code}, status: code, headers: headers);

/// Random that always returns the top of its range: jitter becomes the cap.
class _Max implements Random {
  @override
  bool nextBool() => true;
  @override
  double nextDouble() => 1;
  @override
  int nextInt(int max) => max - 1;
}

class Harness {
  new(
    List<FakeReply> replies, {
    RetryOptions? options,
    this.now,
    AuthOptions? auth,
  }) : adapter = FakeAdapter(replies) {
    client = ApiClient(
      baseUrl: Uri.parse('https://api.test/'),
      adapter: adapter,
      auth: auth,
    );
    client.dio.interceptors.add(
      RetryInterceptor(
        options ?? const RetryOptions(),
        client.dio,
        sleep: (d, until) async => waits.add(d),
        random: _Max(),
        now: () => now ?? DateTime.utc(2026),
      ),
    );
  }

  final FakeAdapter adapter;
  final DateTime? now;
  final List<Duration> waits = [];
  late final ApiClient client;
}

void main() {
  test('retries a 503 on GET and returns the later success', () async {
    final h = Harness([status(503), ok()]);
    final body = await h.client.get<Map<String, Object?>>('/a');
    expect(body, {'ok': true});
    expect(h.adapter.calls, 2);
    expect(h.waits, hasLength(1));
  });

  test('retries each default status and a connection error', () async {
    for (final code in [408, 429, 502, 503, 504]) {
      final h = Harness([status(code), ok()]);
      await h.client.get<Object?>('/a');
      expect(h.adapter.calls, 2, reason: '$code');
    }
    final h = Harness([
      FakeReply.failure(DioExceptionType.connectionError),
      ok(),
    ]);
    await h.client.get<Object?>('/a');
    expect(h.adapter.calls, 2);
  });

  test('does not retry timeouts, 500 or 404', () async {
    for (final reply in [
      FakeReply.failure(DioExceptionType.receiveTimeout),
      FakeReply.failure(DioExceptionType.connectionTimeout),
      status(500),
      status(404),
    ]) {
      final h = Harness([reply, ok()]);
      await expectLater(h.client.get<Object?>('/a'), throwsA(isA<ApiError>()));
      expect(h.adapter.calls, 1);
    }
  });

  test(
    'does not retry POST or PATCH, retries PUT DELETE HEAD OPTIONS',
    () async {
      final post = Harness([status(503), ok()]);
      await expectLater(
        post.client.post<Object?>('/a'),
        throwsA(isA<StatusError>()),
      );
      expect(post.adapter.calls, 1);
      final patch = Harness([status(503), ok()]);
      await expectLater(
        patch.client.patch<Object?>('/a'),
        throwsA(isA<StatusError>()),
      );
      expect(patch.adapter.calls, 1);

      final put = Harness([status(503), ok()]);
      await put.client.put<Object?>('/a');
      expect(put.adapter.calls, 2);
      final del = Harness([status(503), ok()]);
      await del.client.delete<Object?>('/a');
      expect(del.adapter.calls, 2);
      final head = Harness([status(503), ok()]);
      await head.client.dio.request<Object?>(
        '/a',
        options: Options(method: 'head'),
      );
      expect(head.adapter.calls, 2);
      final opts = Harness([status(503), ok()]);
      await opts.client.dio.request<Object?>(
        '/a',
        options: Options(method: 'OPTIONS'),
      );
      expect(opts.adapter.calls, 2);
    },
  );

  test('custom methods allow retrying a POST', () async {
    final h = Harness([
      status(503),
      ok(),
    ], options: const RetryOptions(methods: {'POST'}));
    await h.client.post<Object?>('/a');
    expect(h.adapter.calls, 2);
  });

  test('stops after attempts retries and throws the last error', () async {
    final h = Harness([status(503)], options: const RetryOptions(attempts: 3));
    await expectLater(
      h.client.get<Object?>('/a'),
      throwsA(isA<StatusError>().having((e) => e.status, 'status', 503)),
    );
    expect(h.adapter.calls, 4);
    expect(h.waits, hasLength(3));
  });

  test('attempts 0 never retries', () async {
    final h = Harness([
      status(503),
      ok(),
    ], options: const RetryOptions(attempts: 0));
    await expectLater(h.client.get<Object?>('/a'), throwsA(isA<StatusError>()));
    expect(h.adapter.calls, 1);
  });

  test('backoff is exponential with full jitter, capped by maxDelay', () async {
    final h = Harness(
      [status(503)],
      options: const RetryOptions(attempts: 4, maxDelay: Duration(seconds: 1)),
    );
    await expectLater(h.client.get<Object?>('/a'), throwsA(isA<StatusError>()));
    // Random returns the top of the range: 200ms, 400ms, 800ms, then capped.
    expect(h.waits, [
      const Duration(milliseconds: 200),
      const Duration(milliseconds: 400),
      const Duration(milliseconds: 800),
      const Duration(seconds: 1),
    ]);
  });

  test('jitter never exceeds the ceiling', () async {
    final adapter = FakeAdapter([status(503), ok()]);
    final waits = <Duration>[];
    final client = ApiClient(
      baseUrl: Uri.parse('https://api.test/'),
      adapter: adapter,
    );
    client.dio.interceptors.add(
      RetryInterceptor(
        const RetryOptions(),
        client.dio,
        sleep: (d, until) async => waits.add(d),
        random: Random(1),
      ),
    );
    await client.get<Object?>('/a');
    expect(waits.single, lessThanOrEqualTo(const Duration(milliseconds: 200)));
  });

  test('a custom delay replaces the backoff', () async {
    final h = Harness([
      status(503),
      status(503),
      ok(),
    ], options: RetryOptions(delay: (attempt) => Duration(seconds: attempt)));
    await h.client.get<Object?>('/a');
    expect(h.waits, [const Duration(seconds: 1), const Duration(seconds: 2)]);
  });

  test('honours Retry-After in seconds', () async {
    final h = Harness([
      status(
        429,
        headers: {
          'retry-after': ['3'],
        },
      ),
      ok(),
    ]);
    await h.client.get<Object?>('/a');
    expect(h.waits, [const Duration(seconds: 3)]);
  });

  test('honours Retry-After as an HTTP date', () async {
    final h = Harness([
      status(
        503,
        headers: {
          'retry-after': ['Thu, 01 Jan 2026 00:00:05 GMT'],
        },
      ),
      ok(),
    ], now: DateTime.utc(2026));
    await h.client.get<Object?>('/a');
    expect(h.waits, [const Duration(seconds: 5)]);
  });

  test('a Retry-After date in the past retries at once', () async {
    final h = Harness([
      status(
        503,
        headers: {
          'retry-after': ['Wed, 31 Dec 2025 23:00:00 GMT'],
        },
      ),
      ok(),
    ], now: DateTime.utc(2026));
    await h.client.get<Object?>('/a');
    expect(h.waits, [Duration.zero]);
  });

  test('Retry-After beyond maxDelay is the final reply', () async {
    final h = Harness([
      status(
        503,
        headers: {
          'retry-after': ['60'],
        },
      ),
      ok(),
    ], options: const RetryOptions());
    await expectLater(h.client.get<Object?>('/a'), throwsA(isA<StatusError>()));
    expect(h.adapter.calls, 1);
  });

  test('an unparsable Retry-After falls back to the backoff', () async {
    final h = Harness([
      status(
        503,
        headers: {
          'retry-after': ['soon'],
        },
      ),
      ok(),
    ]);
    await h.client.get<Object?>('/a');
    expect(h.waits, [const Duration(milliseconds: 200)]);
  });

  test('the default wait is cut short by the cancel token', () async {
    final adapter = FakeAdapter([status(503), ok()]);
    final client = ApiClient(
      baseUrl: Uri.parse('https://api.test/'),
      adapter: adapter,
      retry: const RetryOptions(delay: _hour, maxDelay: Duration(hours: 2)),
    );
    final token = CancelToken();
    final call = client.get<Object?>('/a', cancelToken: token);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    token.cancel('stop');
    await expectLater(call, throwsA(isA<CancelledError>()));
    expect(adapter.calls, 1);
  });

  test('a token already cancelled is not retried', () async {
    final h = Harness([status(503), ok()]);
    final token = CancelToken()..cancel('x');
    await expectLater(
      h.client.get<Object?>('/a', cancelToken: token),
      throwsA(isA<CancelledError>()),
    );
    expect(h.adapter.calls, lessThanOrEqualTo(1));
  });

  test('a 401 refresh and a retry work together', () async {
    var token = 'old';
    final h = Harness(
      [status(401), status(503), ok()],
      auth: AuthOptions(token: () => token, refresh: () async => token = 'new'),
    );
    final body = await h.client.get<Map<String, Object?>>('/a');
    expect(body, {'ok': true});
    expect(h.adapter.calls, 3);
    expect(h.adapter.requests.last.headers['authorization'], 'Bearer new');
  });

  test('a replayed request keeps its body', () async {
    final h = Harness([
      status(503),
      ok(),
    ], options: const RetryOptions(methods: {'POST'}));
    await h.client.post<Object?>('/a', data: {'k': 1});
    expect(h.adapter.requests.last.data, {'k': 1});
  });
}

Duration _hour(int attempt) => const Duration(hours: 1);
