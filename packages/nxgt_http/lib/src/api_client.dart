import 'package:dio/dio.dart';

import 'package:nxgt_http/src/api_error.dart';
import 'package:nxgt_http/src/auth_interceptor.dart';
import 'package:nxgt_http/src/retry_interceptor.dart';

/// Turns a decoded JSON body (`Map`, `List`, scalar or null) into a [T].
typedef Decode<T> = T Function(Object? json);

/// A typed HTTP client on top of [Dio]. Every failure is thrown as an
/// [ApiError]; there is no result type.
class ApiClient {
  /// Creates a client for [baseUrl].
  ///
  /// [headers] with a null value are left out. [interceptors] run in the
  /// given order, after the auth and retry interceptors. [auth] adds the
  /// `Authorization` header and renews the token on a 401; [retry] sends
  /// failed repeatable requests again. Dio runs `onError` in insertion order,
  /// so a 401 is refreshed before a retry is considered. [adapter] replaces
  /// the transport (tests).
  new({
    required Uri baseUrl,
    Map<String, Object?>? headers,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    AuthOptions? auth,
    RetryOptions? retry,
    List<Interceptor> interceptors = const [],
    HttpClientAdapter? adapter,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl.toString(),
           headers: _withoutNulls(headers),
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
         ),
       ) {
    if (adapter != null) dio.httpClientAdapter = adapter;
    if (auth != null) dio.interceptors.add(AuthInterceptor(auth, dio));
    if (retry != null) dio.interceptors.add(RetryInterceptor(retry, dio));
    dio.interceptors.addAll(interceptors);
  }

  /// Uses an already configured [dio] as is.
  new wrap(this.dio);

  /// The underlying Dio, public on purpose: add interceptors or reach options
  /// this client does not wrap.
  final Dio dio;

  /// GET [path]. With [decode] the JSON body becomes a [T]; without it the
  /// body is cast to [T].
  Future<T> get<T>(
    String path, {
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    Options? options,
  }) => _send('GET', path, query, null, decode, cancelToken, options);

  /// POST [path] with [data] as the body.
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    Options? options,
  }) => _send('POST', path, query, data, decode, cancelToken, options);

  /// PUT [path] with [data] as the body.
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    Options? options,
  }) => _send('PUT', path, query, data, decode, cancelToken, options);

  /// PATCH [path] with [data] as the body.
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    Options? options,
  }) => _send('PATCH', path, query, data, decode, cancelToken, options);

  /// DELETE [path], with an optional [data] body.
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    Decode<T>? decode,
    CancelToken? cancelToken,
    Options? options,
  }) => _send('DELETE', path, query, data, decode, cancelToken, options);

  Future<T> _send<T>(
    String method,
    String path,
    Map<String, Object?>? query,
    Object? data,
    Decode<T>? decode,
    CancelToken? cancelToken,
    Options? options,
  ) async {
    final Response<Object?> response;
    try {
      response = await dio.request<Object?>(
        path,
        data: data,
        queryParameters: _withoutNulls(query),
        cancelToken: cancelToken,
        options: (options ?? Options()).copyWith(method: method),
      );
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
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
