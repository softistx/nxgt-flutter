import 'package:dio/dio.dart';

import 'package:nxgt_http/src/api_error.dart';
import 'package:nxgt_http/src/auth_interceptor.dart';
import 'package:nxgt_http/src/call_scope.dart';
import 'package:nxgt_http/src/http_logger.dart';
import 'package:nxgt_http/src/retry_interceptor.dart';

/// Turns a decoded JSON body (`Map`, `List`, scalar or null) into a [T].
typedef Decode<T> = T Function(Object? json);

/// A typed HTTP client on top of [Dio]. Every failure is thrown as an
/// [ApiError]; there is no result type.
class ApiClient {
  /// Creates a client for [baseUrl].
  ///
  /// [headers] with a null value are left out. The interceptors run in a
  /// fixed order: [logger], then [auth], then [retry], then [interceptors] in
  /// the given order. [logger] reports each attempt; [auth] adds the
  /// `Authorization` header and renews the token on a 401; [retry] sends
  /// failed repeatable requests again. Dio runs `onError` in insertion order,
  /// so the logger sees a failed attempt first, then a 401 is refreshed
  /// before a retry is considered. [adapter] replaces the transport (tests).
  new({
    required Uri baseUrl,
    Map<String, Object?>? headers,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    AuthOptions? auth,
    RetryOptions? retry,
    HttpLogger? logger,
    List<Interceptor> interceptors = const [],
    HttpClientAdapter? adapter,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl.toString(),
           headers: _withoutNulls(headers),
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
         ),
       ),
       _scope = CallScope(null) {
    if (adapter != null) dio.httpClientAdapter = adapter;
    if (logger != null) dio.interceptors.add(logger);
    if (auth != null) dio.interceptors.add(AuthInterceptor(auth, dio));
    if (retry != null) dio.interceptors.add(RetryInterceptor(retry, dio));
    dio.interceptors.addAll(interceptors);
  }

  /// Uses an already configured [dio] as is.
  new wrap(this.dio) : _scope = CallScope(null);

  new _group(this.dio, this._scope);

  final CallScope _scope;

  /// The underlying Dio, public on purpose: add interceptors or reach options
  /// this client does not wrap.
  final Dio dio;

  /// A client for one screen's (or one feature's) calls: it shares this
  /// client's [dio] and interceptors, and its [cancel] stops all of its calls
  /// at once without touching this client or its other groups.
  ///
  /// Cancelling a client also cancels the calls of its groups, so cancelling
  /// the root stops everything in flight. A group stays usable after [cancel]:
  /// the next call starts normally. Groups are not registered anywhere, so a
  /// dropped group is simply garbage collected.
  ApiClient group() => ApiClient._group(dio, CallScope(_scope));

  /// Cancels every call in flight on this client and its groups. Each throws
  /// a `CancelledError` carrying [reason]; nothing is retried or refreshed
  /// afterwards.
  void cancel([Object? reason]) {
    for (final token in [..._scope.tokens]) {
      token.cancel(reason);
    }
  }

  /// GET [path]. With [decode] the JSON body becomes a [T]; without it the
  /// body is cast to [T].
  ///
  /// Every call method also takes [cancelToken] (cancelling it cancels the
  /// call) and [latest]: a key that cancels the previous in-flight call of
  /// this client with the same key, for search-as-you-type.
  Future<T> get<T>(
    String path, {
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    String? latest,
    Options? options,
  }) => _send('GET', path, query, null, decode, cancelToken, latest, options);

  /// POST [path] with [data] as the body.
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    String? latest,
    Options? options,
  }) => _send('POST', path, query, data, decode, cancelToken, latest, options);

  /// PUT [path] with [data] as the body.
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    String? latest,
    Options? options,
  }) => _send('PUT', path, query, data, decode, cancelToken, latest, options);

  /// PATCH [path] with [data] as the body.
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    String? latest,
    Options? options,
  }) => _send('PATCH', path, query, data, decode, cancelToken, latest, options);

  /// DELETE [path], with an optional [data] body.
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    String? latest,
    Options? options,
  }) =>
      _send('DELETE', path, query, data, decode, cancelToken, latest, options);

  Future<T> _send<T>(
    String method,
    String path,
    Map<String, Object?>? query,
    Object? data,
    Decode<T>? decode,
    CancelToken? cancelToken,
    String? latest,
    Options? options,
  ) async {
    final token = _scope.start(cancelToken, latest);
    final Response<Object?> response;
    try {
      response = await dio.request<Object?>(
        path,
        data: data,
        queryParameters: _withoutNulls(query),
        cancelToken: token,
        options: (options ?? Options()).copyWith(method: method),
      );
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    } finally {
      _scope.finish(token, latest);
    }
    try {
      final body = response.data;
      return decode != null ? decode(body) : body as T;
    } on Object catch (e, trace) {
      throw DecodeError(
        method: method,
        path: path,
        cause: e,
        stackTrace: trace,
      );
    }
  }

  static Map<String, Object?> _withoutNulls(Map<String, Object?>? source) => {
    for (final entry in (source ?? const <String, Object?>{}).entries)
      if (entry.value != null) entry.key: entry.value,
  };
}
