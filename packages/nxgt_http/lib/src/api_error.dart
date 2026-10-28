import 'package:dio/dio.dart';

/// The phase of a request that ran out of time.
enum TimeoutStage {
  /// Opening the connection.
  connect,

  /// Sending the request body.
  send,

  /// Waiting for or reading the response.
  receive,
}

/// Why a call made through `ApiClient` failed. Thrown, never returned: switch
/// on the sealed subtypes to handle each case.
sealed class ApiError implements Exception {
  /// Creates an error for the call `[method] [path]`.
  const new({
    required this.method,
    required this.path,
    this.cause,
    this.stackTrace,
  });

  /// Maps a [DioException] to its typed error. An [ApiError] already carried
  /// as the exception's `error` (raised by an interceptor) is returned as is.
  factory fromDio(DioException e) {
    final inner = e.error;
    if (inner is ApiError) return inner;
    final method = e.requestOptions.method;
    final path = e.requestOptions.path;
    final trace = e.stackTrace;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutError(
          method: method,
          path: path,
          timeout: e.requestOptions.connectTimeout ?? Duration.zero,
          stage: TimeoutStage.connect,
          cause: e,
          stackTrace: trace,
        );
      case DioExceptionType.sendTimeout:
        return TimeoutError(
          method: method,
          path: path,
          timeout: e.requestOptions.sendTimeout ?? Duration.zero,
          stage: TimeoutStage.send,
          cause: e,
          stackTrace: trace,
        );
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutError(
          method: method,
          path: path,
          timeout: e.requestOptions.receiveTimeout ?? Duration.zero,
          stage: TimeoutStage.receive,
          cause: e,
          stackTrace: trace,
        );
      case DioExceptionType.badResponse:
        final response = e.response;
        if (response != null) {
          return StatusError(
            method: method,
            path: path,
            status: response.statusCode ?? 0,
            data: response.data,
            response: response,
            cause: e,
            stackTrace: trace,
          );
        }
        return NetworkError(
          method: method,
          path: path,
          cause: e,
          stackTrace: trace,
        );
      case DioExceptionType.cancel:
        return CancelledError(
          method: method,
          path: path,
          reason: e.error,
          cause: e,
          stackTrace: trace,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return NetworkError(
          method: method,
          path: path,
          cause: e.error ?? e,
          stackTrace: trace,
        );
    }
  }

  /// HTTP method of the failed call.
  final String method;

  /// Path of the failed call, as given to the client.
  final String path;

  /// The underlying exception, when there is one.
  final Object? cause;

  /// Stack trace of the underlying exception.
  final StackTrace? stackTrace;

  /// Whether this is a real failure. `false` for a cancellation, which a
  /// caller usually ignores rather than reports.
  bool get isFailure => true;

  String get _name;

  /// Short description used by [toString].
  String get _detail => '';

  @override
  String toString() => '$_name: $method $path$_detail';
}

/// The request never got an answer: no connection, DNS, TLS or CORS failure.
final class NetworkError extends ApiError {
  /// Creates a network error.
  const new({
    required super.method,
    required super.path,
    super.cause,
    super.stackTrace,
  });

  @override
  String get _name => 'NetworkError';
}

/// The request ran out of time in [stage].
final class TimeoutError extends ApiError {
  /// Creates a timeout error.
  const new({
    required super.method,
    required super.path,
    required this.timeout,
    required this.stage,
    super.cause,
    super.stackTrace,
  });

  /// The configured limit that was exceeded (zero when none was recorded).
  final Duration timeout;

  /// The phase that timed out.
  final TimeoutStage stage;

  @override
  String get _detail => ' (${stage.name} timeout after $timeout)';

  @override
  String get _name => 'TimeoutError';
}

/// The server answered with a non-2xx status.
final class StatusError extends ApiError {
  /// Creates a status error.
  const new({
    required super.method,
    required super.path,
    required this.status,
    required this.data,
    required this.response,
    super.cause,
    super.stackTrace,
  });

  /// The HTTP status code.
  final int status;

  /// The decoded response body (often an error document), or null.
  final Object? data;

  /// The full response, with headers.
  final Response<Object?> response;

  @override
  String get _detail => ' (status $status)';

  @override
  String get _name => 'StatusError';
}

/// The reply arrived but could not be turned into the expected type.
final class DecodeError extends ApiError {
  /// Creates a decode error.
  const new({
    required super.method,
    required super.path,
    super.cause,
    super.stackTrace,
  });

  @override
  String get _detail => ' (decode failed: $cause)';

  @override
  String get _name => 'DecodeError';
}

/// The call was cancelled, through a `CancelToken`.
final class CancelledError extends ApiError {
  /// Creates a cancellation.
  const new({
    required super.method,
    required super.path,
    this.reason,
    super.cause,
    super.stackTrace,
  });

  /// What was given to `CancelToken.cancel`, if anything.
  final Object? reason;

  @override
  bool get isFailure => false;

  @override
  String get _detail => ' (cancelled)';

  @override
  String get _name => 'CancelledError';
}

/// Whether [error] is a cancellation, as an [ApiError] or a raw
/// [DioException].
bool isCancelled(Object error) =>
    error is CancelledError ||
    (error is DioException && error.type == DioExceptionType.cancel);
