import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// When and how long [RetryInterceptor] retries.
class RetryOptions {
  /// Creates retry options.
  const new({
    this.attempts = 2,
    this.methods = repeatableMethods,
    this.statuses = retryableStatuses,
    this.delay,
    this.maxDelay = const Duration(seconds: 10),
  });

  /// The methods that are safe to repeat.
  static const repeatableMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};

  /// The statuses that mean "try again".
  static const retryableStatuses = {408, 429, 502, 503, 504};

  /// How many times a failed request is sent again (0 turns retry off).
  final int attempts;

  /// The HTTP methods that may be retried, in upper case.
  final Set<String> methods;

  /// The response statuses that are retried.
  final Set<int> statuses;

  /// The wait before retry number `attempt` (1 for the first retry), used as
  /// is. Without it the wait is an exponential backoff (200 ms, 400 ms, 800 ms
  /// ...) with full jitter. Either way it never exceeds [maxDelay].
  final Duration Function(int attempt)? delay;

  /// The longest wait. A `Retry-After` header asking for more is not waited
  /// for: the response is returned as is.
  final Duration maxDelay;
}

/// Sends a failed request again when it is safe to.
///
/// Retried: the [RetryOptions.methods] only, on a connection error or one of
/// the [RetryOptions.statuses]. Timeouts are not retried, nor is a request
/// whose body is a stream. A `Retry-After` header (seconds or HTTP date) sets
/// the wait; the wait ends at once when the request's `CancelToken` is
/// cancelled.
///
/// Add it after the auth interceptor: Dio runs `onError` in insertion order,
/// so a 401 is refreshed first and the replay is retried like any request.
class RetryInterceptor extends Interceptor {
  /// Creates an interceptor that sends again through [dio], the instance it
  /// is added to.
  ///
  /// [sleep], [random] and [now] replace the real clock for tests. [sleep]
  /// receives a future that completes when the request is cancelled.
  new(
    this.options,
    this.dio, {
    Future<void> Function(Duration delay, Future<void> cancelled)? sleep,
    Random? random,
    DateTime Function()? now,
  }) : _sleep = sleep ?? _timerSleep,
       _random = random ?? Random(),
       _now = now ?? DateTime.now;

  /// The retry rules.
  final RetryOptions options;

  /// The Dio used to send again.
  final Dio dio;

  /// `RequestOptions.extra` key holding the number of retries done.
  static const attemptKey = 'nxgt_http.retry.attempt';

  static const _base = Duration(milliseconds: 200);

  final Future<void> Function(Duration, Future<void>) _sleep;
  final Random _random;
  final DateTime Function() _now;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final done = request.extra[attemptKey] as int? ?? 0;
    if (done >= options.attempts || !_retryable(err)) {
      return handler.next(err);
    }
    final token = request.cancelToken;
    if (token != null && token.isCancelled) return handler.next(err);

    final wait = _wait(err, done + 1);
    if (wait == null) return handler.next(err);

    if (token != null) {
      final cancelled = token.whenCancel.then<void>((_) {});
      await _sleep(wait, cancelled);
      final cancel = token.cancelError;
      if (cancel != null) return handler.reject(cancel);
    } else {
      await _sleep(wait, Completer<void>().future);
    }
    try {
      handler.resolve(await dio.fetch<Object?>(_again(request, done + 1)));
    } on DioException catch (e) {
      handler.reject(e);
    }
  }

  bool _retryable(DioException err) {
    final request = err.requestOptions;
    if (!options.methods.contains(request.method.toUpperCase())) return false;
    if (request.data is Stream) return false;
    final status = err.response?.statusCode;
    return err.type == DioExceptionType.connectionError ||
        (status != null && options.statuses.contains(status));
  }

  /// The wait before retry [attempt], or null when the server asks for more
  /// than [RetryOptions.maxDelay].
  Duration? _wait(DioException err, int attempt) {
    final asked = _retryAfter(err.response);
    if (asked != null) {
      return asked > options.maxDelay ? null : asked;
    }
    final custom = options.delay;
    final Duration wait;
    if (custom != null) {
      wait = custom(attempt);
    } else {
      final ceiling = _base.inMilliseconds * (1 << min(attempt - 1, 20));
      final capped = min(ceiling, options.maxDelay.inMilliseconds);
      // Full jitter: anywhere between 0 and the ceiling.
      wait = Duration(milliseconds: (_random.nextDouble() * capped).round());
    }
    return wait > options.maxDelay ? options.maxDelay : wait;
  }

  Duration? _retryAfter(Response<Object?>? response) {
    final value = response?.headers.value('retry-after')?.trim();
    if (value == null || value.isEmpty) return null;
    final seconds = int.tryParse(value);
    if (seconds != null) {
      return seconds < 0 ? null : Duration(seconds: seconds);
    }
    final date = _httpDate(value);
    if (date == null) return null;
    final wait = date.difference(_now());
    return wait.isNegative ? Duration.zero : wait;
  }

  RequestOptions _again(RequestOptions request, int attempt) {
    final data = request.data;
    return request.copyWith(
      data: data is FormData ? data.clone() : data,
      extra: {...request.extra, attemptKey: attempt},
    );
  }

  static Future<void> _timerSleep(Duration delay, Future<void> cancelled) {
    final done = Completer<void>();
    final timer = Timer(delay, done.complete);
    unawaited(
      cancelled.then((_) {
        timer.cancel();
        if (!done.isCompleted) done.complete();
      }),
    );
    return done.future;
  }

  static const _months = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun',
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec', //
  ];

  /// Parses an RFC 1123 date (`Thu, 01 Jan 2026 00:00:05 GMT`).
  static DateTime? _httpDate(String value) {
    final m = RegExp(
      r'^(?:[A-Za-z]{3},\s*)?(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})\s+'
      r'(\d{2}):(\d{2}):(\d{2})\s+GMT$',
    ).firstMatch(value);
    if (m == null) return null;
    final month = _months.indexOf(m[2]!.toLowerCase());
    if (month < 0) return null;
    return DateTime.utc(
      int.parse(m[3]!),
      month + 1,
      int.parse(m[1]!),
      int.parse(m[4]!),
      int.parse(m[5]!),
      int.parse(m[6]!),
    );
  }
}
