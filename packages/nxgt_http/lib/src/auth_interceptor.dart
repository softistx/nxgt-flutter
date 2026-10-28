import 'dart:async';

import 'package:dio/dio.dart';

/// How [AuthInterceptor] gets and renews credentials.
class AuthOptions {
  /// Creates auth options.
  const new({required this.token, this.refresh, this.scheme = 'Bearer'});

  /// Returns the current access token, or null when signed out (no header is
  /// sent). Called before every request.
  final FutureOr<String?> Function() token;

  /// Renews the credentials after a 401: store the new token where [token]
  /// reads it. Throw to give up. Without it a 401 is returned as is.
  final Future<void> Function()? refresh;

  /// The `Authorization` scheme placed before the token.
  final String scheme;
}

/// Adds the `Authorization` header and, on a 401, renews the token once and
/// replays the request.
///
/// Concurrent 401s share one [AuthOptions.refresh] call. A replayed request is
/// never refreshed again, so there is no loop. When the refresh throws, or
/// leaves the token unchanged, the caller gets the original 401 as a
/// `StatusError`; a thrown refresh error is kept as the cause of the
/// `DioException` behind it.
class AuthInterceptor extends Interceptor {
  /// Creates an interceptor that replays through [dio], the instance it is
  /// added to.
  new(this.options, this.dio);

  /// The credentials callbacks.
  final AuthOptions options;

  /// The Dio used to replay a request.
  final Dio dio;

  /// `RequestOptions.extra` key set on a replayed request.
  static const replayedKey = 'nxgt_http.auth.replayed';

  static const _managedKey = 'nxgt_http.auth.managed';

  Future<void>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      await _authorize(options);
    } on Object catch (e, trace) {
      return handler.reject(
        DioException(requestOptions: options, error: e, stackTrace: trace),
      );
    }
    handler.next(options);
  }

  Future<void> _authorize(RequestOptions request) async {
    if (_header(request, 'authorization') != null) return;
    final token = await options.token();
    if (token != null && token.isNotEmpty) {
      request.headers['authorization'] = '${options.scheme} $token';
      request.extra[_managedKey] = true;
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final refresh = options.refresh;
    if (err.response?.statusCode != 401 ||
        refresh == null ||
        request.extra[replayedKey] == true) {
      return handler.next(err);
    }
    final sent = _header(request, 'authorization');
    // The caller chose its own credential: not ours to renew.
    if (sent != null && request.extra[_managedKey] != true) {
      return handler.next(err);
    }
    try {
      final before = await options.token();
      final stale = before != null && sent != '${options.scheme} $before';
      if (!stale) {
        await (_refreshing ??= _refresh(refresh));
        final after = await options.token();
        if (after == null || after == before) return handler.next(err);
      }
    } on Object catch (e, trace) {
      return handler.next(
        DioException(
          requestOptions: request,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: e,
          stackTrace: trace,
        ),
      );
    }
    try {
      handler.resolve(await dio.fetch<Object?>(_replay(request)));
    } on DioException catch (e) {
      handler.reject(e);
    }
  }

  Future<void> _refresh(Future<void> Function() refresh) async {
    try {
      await Future<void>.sync(refresh);
    } finally {
      _refreshing = null;
    }
  }

  RequestOptions _replay(RequestOptions request) {
    final data = request.data;
    return request.copyWith(
      data: data is FormData ? data.clone() : data,
      headers: {
        for (final entry in request.headers.entries)
          if (entry.key.toLowerCase() != 'authorization')
            entry.key: entry.value,
      },
      extra: {...request.extra, replayedKey: true},
    );
  }

  static String? _header(RequestOptions request, String name) {
    for (final entry in request.headers.entries) {
      if (entry.key.toLowerCase() == name) return entry.value?.toString();
    }
    return null;
  }
}
