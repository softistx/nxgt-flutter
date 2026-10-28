# Retry

`RetryOptions` makes the client send a failed request again, only when that is
safe.

```dart
final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.com/v1/'),
  retry: const RetryOptions(), // 2 retries, 200 ms backoff, 10 s at most
);
```

## What is retried

- **Methods:** `GET`, `HEAD`, `OPTIONS`, `PUT` and `DELETE`. A `POST` or
  `PATCH` is never repeated unless you list it in `methods` (do that only when
  the server deduplicates, for example with an idempotency key).
- **Failures:** a connection error, or a response with status 408, 429, 502,
  503 or 504 (`statuses` changes the set).
- **Not retried:** timeouts (the server may still be working), other statuses,
  a request whose body is a `Stream`, a cancelled request.

After `attempts` retries (default 2) the last failure is thrown as usual.
`attempts: 0` turns retry off.

## How long it waits

- **Backoff with full jitter:** the ceiling is 200 ms, 400 ms, 800 ms ... and
  the wait is a random value between zero and that ceiling, so clients that
  failed together do not come back together.
- **`delay`:** `delay: (attempt) => Duration(seconds: attempt)` replaces the
  backoff; its value is used as is. `attempt` is 1 for the first retry.
- **`Retry-After`:** when the response has the header, in seconds (`3`) or as an
  HTTP date, it sets the wait and overrides both the backoff and a custom
  `delay`. A date in the past retries at once. Only RFC 1123 dates
  (`Thu, 01 Jan 2026 00:00:05 GMT`) are parsed; RFC 850, asctime and any
  other unreadable value fall back to the backoff.
- **`maxDelay`** (default 10 s) caps every wait. When `Retry-After` asks for
  more than `maxDelay`, the client does not wait: the response is returned as
  it is, a `StatusError` with its status.

## Cancelling

The wait ends as soon as the request's `CancelToken` is cancelled, and the call
throws a `CancelledError`. Nothing is sent after that.

```dart
import 'package:dio/dio.dart'; // CancelToken

final token = CancelToken();
final call = client.get<Object?>('/slow', cancelToken: token);
token.cancel('screen closed'); // also stops a pending wait
```

## With authentication

Dio runs `onError` in insertion order, and the client adds the logger, then
auth, then retry. A 401 is therefore refreshed and replayed first; the replay
goes through retry
like any request, so a 503 after a refresh is retried too. Retry never retries a
401.

## On a plain Dio

```dart
import 'package:dio/dio.dart';
import 'package:nxgt_http/nxgt_http.dart';

final dio = Dio();
dio.interceptors.add(RetryInterceptor(const RetryOptions(), dio));
```

The counter lives in `RequestOptions.extra['nxgt_http.retry.attempt']`.
