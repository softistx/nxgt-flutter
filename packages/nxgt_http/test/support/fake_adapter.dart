import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// One scripted reply of a [FakeAdapter].
class FakeReply {
  /// A reply with [status] and a JSON [body].
  new json(
    Object? body, {
    this.status = 200,
    Map<String, List<String>> headers = const {},
    this.delay = Duration.zero,
  }) : data = body == null ? '' : jsonEncode(body),
       error = null,
       headers = {
         Headers.contentTypeHeader: [Headers.jsonContentType],
         ...headers,
       };

  /// A reply that fails with a transport error of [type].
  new failure(DioExceptionType type, {this.delay = Duration.zero})
    : error = type,
      status = 0,
      data = '',
      headers = const {};

  /// Status code (0 for a failure).
  final int status;

  /// Raw body.
  final String data;

  /// Response headers.
  final Map<String, List<String>> headers;

  /// Transport error type, when the reply is a failure.
  final DioExceptionType? error;

  /// Time to wait before answering.
  final Duration delay;
}

/// A hand-written `HttpClientAdapter`: replies come from a queue, requests
/// are recorded.
class FakeAdapter implements HttpClientAdapter {
  /// Creates an adapter that answers with [replies], in order. When the queue
  /// runs dry the last reply is repeated.
  new([Iterable<FakeReply> replies = const []]) : _replies = [...replies];

  final List<FakeReply> _replies;
  FakeReply? _last;

  /// Every request received, in order.
  final List<RequestOptions> requests = [];

  /// Number of requests received.
  int get calls => requests.length;

  /// Whether [close] was called.
  bool closed = false;

  /// Queues one more reply.
  void enqueue(FakeReply reply) => _replies.add(reply);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final reply = _replies.isNotEmpty ? _replies.removeAt(0) : _last;
    if (reply == null) {
      throw StateError('FakeAdapter: no reply queued for ${options.uri}');
    }
    _last = reply;
    if (reply.delay > Duration.zero) await Future<void>.delayed(reply.delay);
    final type = reply.error;
    if (type != null) {
      throw DioException(requestOptions: options, type: type);
    }
    return ResponseBody.fromString(
      reply.data,
      reply.status,
      headers: reply.headers,
    );
  }

  @override
  void close({bool force = false}) => closed = true;
}
