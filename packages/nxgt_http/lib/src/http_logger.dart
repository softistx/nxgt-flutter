import 'package:dio/dio.dart';

import 'package:nxgt_http/src/api_error.dart';

/// What one HTTP attempt did, handed to the `sink` of an [HttpLogger].
///
/// Immutable: the maps are unmodifiable. Headers named in
/// [HttpLogger.redact] carry [HttpLogger.redacted] as their value; the bodies
/// are null unless [HttpLogger.bodies] is true.
final class HttpLogRecord {
  /// Creates a record.
  new({
    required this.method,
    required this.url,
    required this.duration,
    this.status,
    this.error,
    Map<String, String> requestHeaders = const {},
    Map<String, String> responseHeaders = const {},
    this.requestBody,
    this.responseBody,
  }) : requestHeaders = Map.unmodifiable(requestHeaders),
       responseHeaders = Map.unmodifiable(responseHeaders);

  /// HTTP method, in upper case.
  final String method;

  /// The full URL, query string included.
  final Uri url;

  /// Time from sending the request to the answer or the failure.
  final Duration duration;

  /// The response status, or null when there was no response.
  final int? status;

  /// Why the attempt failed, as the typed error the call would throw
  /// (`StatusError` for a non-2xx answer, `NetworkError`, `TimeoutError`,
  /// `CancelledError`...), or null when it ended with a 2xx/3xx response.
  final ApiError? error;

  /// Request headers, values redacted as configured.
  final Map<String, String> requestHeaders;

  /// Response headers, values redacted as configured.
  final Map<String, String> responseHeaders;

  /// The request body, only when bodies are logged.
  final Object? requestBody;

  /// The response body, only when bodies are logged.
  final Object? responseBody;

  /// Whether the attempt ended in an error.
  bool get isError => error != null;

  @override
  String toString() =>
      '$method $url -> ${error?.runtimeType ?? status} '
      '(${duration.inMilliseconds} ms)';
}

/// A Dio interceptor that reports every attempt to a `sink`, with the
/// sensitive headers redacted. Works on a plain `Dio` and through
/// `ApiClient(logger: ...)`.
///
/// One record per attempt: a request replayed by the auth or retry
/// interceptor is reported once for the failed attempt and once for the
/// replay. Query strings are logged as they are, so keep secrets out of the
/// URL.
class HttpLogger extends Interceptor {
  /// Creates a logger that calls [sink] once per attempt.
  ///
  /// Header names are matched case-insensitively. The [defaultRedact] set is
  /// always redacted; [redact] adds names to it. Bodies are left
  /// out unless [bodies] is true.
  new({required this.sink, Set<String> redact = const {}, this.bodies = false})
    : redact = {
        ...defaultRedact,
        for (final name in redact) name.toLowerCase(),
      };

  /// Receives each record. An exception it throws is swallowed: logging never
  /// breaks a call.
  final void Function(HttpLogRecord record) sink;

  /// Lower-cased names of the headers whose value is replaced: the
  /// [defaultRedact] set plus the names given to the constructor.
  final Set<String> redact;

  /// Whether request and response bodies are put in the records.
  final bool bodies;

  /// Headers that are always redacted.
  static const defaultRedact = {
    'authorization',
    'proxy-authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
  };

  /// What replaces a redacted header value.
  static const redacted = '[redacted]';

  static const _startKey = 'nxgt_http.log.start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _emit(response.requestOptions, response: response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _emit(
      err.requestOptions,
      response: err.response,
      error: ApiError.fromDio(err),
    );
    handler.next(err);
  }

  void _emit(
    RequestOptions request, {
    Response<dynamic>? response,
    ApiError? error,
  }) {
    final watch = request.extra[_startKey];
    final elapsed = watch is Stopwatch ? watch.elapsed : Duration.zero;
    if (watch is Stopwatch) watch.stop();
    try {
      sink(
        HttpLogRecord(
          method: request.method.toUpperCase(),
          url: request.uri,
          duration: elapsed,
          status: response?.statusCode,
          error: error,
          requestHeaders: _flat(request.headers),
          responseHeaders: _flat(response?.headers.map ?? const {}),
          requestBody: bodies ? request.data : null,
          responseBody: bodies ? response?.data : null,
        ),
      );
    } on Object {
      // A broken sink must not fail the call.
    }
  }

  Map<String, String> _flat(Map<String, dynamic> headers) => {
    for (final entry in headers.entries)
      if (entry.value != null)
        entry.key: redact.contains(entry.key.toLowerCase())
            ? redacted
            : switch (entry.value) {
                final List<dynamic> list => list.join(', '),
                final value => '$value',
              },
  };
}
