import 'package:dio/dio.dart';
import 'package:nxgt_http/nxgt_http.dart';
import 'package:test/test.dart';

DioException dioError(
  DioExceptionType type, {
  Response<Object?>? response,
  Object? error,
  RequestOptions? options,
}) {
  final request =
      options ??
      RequestOptions(
        path: '/users',
        method: 'GET',
        connectTimeout: const Duration(seconds: 1),
        sendTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 3),
      );
  return DioException(
    requestOptions: request,
    type: type,
    response: response,
    error: error,
  );
}

void main() {
  group('ApiError.fromDio', () {
    test('maps timeouts with their stage and configured duration', () {
      final connect = ApiError.fromDio(
        dioError(DioExceptionType.connectionTimeout),
      );
      final send = ApiError.fromDio(dioError(DioExceptionType.sendTimeout));
      final receive = ApiError.fromDio(
        dioError(DioExceptionType.receiveTimeout),
      );

      expect(connect, isA<TimeoutError>());
      expect((connect as TimeoutError).stage, TimeoutStage.connect);
      expect(connect.timeout, const Duration(seconds: 1));
      expect((send as TimeoutError).stage, TimeoutStage.send);
      expect(send.timeout, const Duration(seconds: 2));
      expect((receive as TimeoutError).stage, TimeoutStage.receive);
      expect(receive.timeout, const Duration(seconds: 3));
    });

    test('maps a timeout without a configured duration to zero', () {
      final error = ApiError.fromDio(
        dioError(
          DioExceptionType.connectionTimeout,
          options: RequestOptions(path: '/x'),
        ),
      );

      expect((error as TimeoutError).timeout, Duration.zero);
    });

    test('maps a bad response to a StatusError with data and response', () {
      final request = RequestOptions(path: '/users', method: 'POST');
      final response = Response<Object?>(
        requestOptions: request,
        statusCode: 422,
        data: {'message': 'nope'},
      );

      final error = ApiError.fromDio(
        dioError(
          DioExceptionType.badResponse,
          response: response,
          options: request,
        ),
      );

      expect(error, isA<StatusError>());
      error as StatusError;
      expect(error.status, 422);
      expect(error.data, {'message': 'nope'});
      expect(error.response, same(response));
      expect(error.method, 'POST');
      expect(error.path, '/users');
      expect(error.isFailure, isTrue);
    });

    test('maps a cancel to CancelledError carrying the reason', () {
      final error = ApiError.fromDio(
        dioError(DioExceptionType.cancel, error: 'screen closed'),
      );

      expect(error, isA<CancelledError>());
      expect((error as CancelledError).reason, 'screen closed');
      expect(error.isFailure, isFalse);
    });

    test('maps transport failures to NetworkError', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.badCertificate,
        DioExceptionType.unknown,
      ]) {
        final error = ApiError.fromDio(dioError(type, error: 'boom'));
        expect(error, isA<NetworkError>(), reason: '$type');
        expect(error.cause, 'boom');
        expect(error.isFailure, isTrue);
      }
    });

    test('keeps the DioException as cause and its stack trace', () {
      final source = dioError(DioExceptionType.connectionError);

      final error = ApiError.fromDio(source);

      expect(error.cause, same(source));
      expect(error.stackTrace, source.stackTrace);
    });

    test('toString names the type, method, path and status', () {
      final error = StatusError(
        method: 'GET',
        path: '/users',
        status: 500,
        data: null,
        response: Response<Object?>(requestOptions: RequestOptions()),
      );

      expect(error.toString(), contains('StatusError'));
      expect(error.toString(), contains('GET /users'));
      expect(error.toString(), contains('500'));
    });
  });

  group('isCancelled', () {
    test('is true for CancelledError and a cancel DioException', () {
      expect(
        isCancelled(const CancelledError(method: 'GET', path: '/x')),
        isTrue,
      );
      expect(isCancelled(dioError(DioExceptionType.cancel)), isTrue);
    });

    test('is false for other errors', () {
      expect(
        isCancelled(const NetworkError(method: 'GET', path: '/x')),
        isFalse,
      );
      expect(isCancelled(StateError('x')), isFalse);
    });
  });

  test('the sealed hierarchy is exhaustive', () {
    String name(ApiError e) => switch (e) {
      NetworkError() => 'network',
      TimeoutError() => 'timeout',
      StatusError() => 'status',
      DecodeError() => 'decode',
      CancelledError() => 'cancelled',
    };

    expect(
      name(const DecodeError(method: 'GET', path: '/x', cause: 'bad')),
      'decode',
    );
    expect(
      name(
        const TimeoutError(
          method: 'GET',
          path: '/x',
          timeout: Duration.zero,
          stage: TimeoutStage.send,
        ),
      ),
      'timeout',
    );
  });
}
