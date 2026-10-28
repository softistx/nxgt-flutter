import 'package:dio/dio.dart';

/// A successful reply: the decoded body with the status and headers that
/// `get`, `post` and the other call methods drop.
final class ApiResponse<T> {
  /// Creates a response.
  const new({
    required this.data,
    required this.statusCode,
    required this.headers,
  });

  /// The body, decoded with `decode` when one was given.
  final T data;

  /// The HTTP status code (2xx; any other status is thrown as a
  /// `StatusError`).
  final int statusCode;

  /// The response headers. Lookups by name are case-insensitive:
  /// `headers.value('x-total-count')`.
  final Headers headers;
}
