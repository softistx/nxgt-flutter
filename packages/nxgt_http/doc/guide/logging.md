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
| `errorType` | A `DioExceptionType` when the attempt failed (`badResponse` for a non-2xx answer, `connectionError`, `connectionTimeout`, `cancel`...), else null. `isError` is the short form. |
| `requestHeaders`, `responseHeaders` | One string per header (several values are joined with `, `). |
| `requestBody`, `responseBody` | Null unless `bodies: true`. |

## Redaction

`authorization`, `cookie` and `set-cookie` are replaced by `[redacted]` in both
request and response headers, whatever their case. `redact` replaces that set:

```dart
HttpLogger(
  sink: print,
  redact: {'authorization', 'cookie', 'set-cookie', 'x-api-key'},
);
```

Redaction covers headers only. Keep secrets out of the URL: the query string is
logged as it is.

## Bodies

Bodies are left out by default, because they hold passwords and personal data.
`bodies: true` adds the request data and the decoded response data to each
record; do it in development only, or filter in your `sink`.

## Order and retries

The logger is the first interceptor, then auth, retry and yours. It sees the
request as the caller wrote it (the `Authorization` header that auth adds is
therefore not in the record). A request that is refreshed or retried makes
one record per attempt: a 503 then a 200 gives two records.

A `sink` that throws is ignored; logging never fails a call.
