# Logging

`HttpLogger` reports every HTTP attempt to a function you give it, with the
sensitive headers redacted. It is a plain Dio interceptor: use it through
`ApiClient` or on any `Dio`.

```dart
final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.com/v1/'),
  logger: HttpLogger(sink: (record) => print(record)),
);
// GET https://api.example.com/v1/me?page=2 -> 200 (84 ms)
```

On a Dio you built yourself:

```dart
final dio = Dio()..interceptors.add(HttpLogger(sink: myLogger.info));
```

## What a record holds

`HttpLogRecord` is an immutable value (its header maps cannot be modified):

| Field | Meaning |
| --- | --- |
| `method`, `url` | The request, with its query string. |
| `status` | The response status, null when nothing came back. |
| `duration` | From sending the request to the answer or the failure. |
| `error` | The typed `ApiError` the attempt would throw (`StatusError` for a non-2xx answer, `NetworkError`, `TimeoutError`, `CancelledError`...), else null. `isError` is the short form. |
| `requestHeaders`, `responseHeaders` | One string per header (several values are joined with `, `). |
| `requestBody`, `responseBody` | Null unless `bodies: true`. |

## Redaction

`authorization`, `proxy-authorization`, `cookie`, `set-cookie` and `x-api-key`
are always replaced by `[redacted]` in request and response headers, whatever
their case (`HttpLogger.defaultRedact`). `redact` adds names to that set; it
never removes one:

```dart
HttpLogger(sink: print, redact: {'x-session-token'});
```

Redaction covers headers only. Keep secrets out of the URL: the query string is
logged as it is.

## Bodies

Bodies are left out by default, because they hold passwords and personal data.
`bodies: true` adds the request data and the decoded response data to each
record; do it in development only, or filter in your `sink`.

## Order and retries

The logger is the first interceptor, then auth, retry and yours. A record holds
the headers as they were sent, so the `Authorization` header that auth added is
there, redacted. A request that is refreshed or retried makes one record per
attempt: a 503 then a 200 gives two records. A cancel during a retry wait ends
the call without a further record (the failed attempt already has its own).

## Errors in the sink

A `sink` that throws is ignored: logging never fails a call, and nothing is
printed about it. The `try` is synchronous, so an async sink whose future
rejects is **not** caught: handle errors inside it.

```dart
HttpLogger(sink: (record) => unawaited(upload(record).catchError((_) {})));
```
