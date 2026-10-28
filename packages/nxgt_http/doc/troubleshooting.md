# Troubleshooting

Entries are added as problems are found: the exact message, when, why, the fix.

## `NetworkError: GET /me` in the browser but not elsewhere

On the web, a request the browser blocks (CORS, mixed content) reaches the
client as a connection failure, so it is a `NetworkError` whose `cause` has no
status. Check the browser console for the blocked origin and allow it on the
server.

## `DecodeError: GET /me (decode failed: …)` on a call that returned 200

The body arrived, but `decode` threw or the body is not of type `T`. The
original exception is in `error.cause` and its trace in `error.stackTrace`.
Pass a `decode` function for anything other than a raw JSON `Map` or `List`:

```dart
final user = await client.get('/me', decode: User.fromJson);
```

## `StatusError: POST /me (status 401)` even though `refresh` ran

`refresh` ran but `token` returned the same value (or null), so the request was
not replayed and the 401 is thrown. Make `refresh` store the new token where
`token` reads it, before it completes.

## `NetworkError: GET /me` whose `cause` is your own exception

The `token` callback of `AuthOptions` threw (a locked keychain, a storage read
that failed). The request is never sent: the exception is rejected before the
network, and it reaches you as a `NetworkError` whose `cause` is what `token`
threw. Return `null` for "signed out" instead of throwing, and catch the rest
inside the callback:

```dart
AuthOptions(
  token: () async {
    try {
      return await storage.read('access');
    } on Object {
      return null; // sends no header; a 401 then runs `refresh`
    }
  },
)
```

## `StatusError: GET /me (status 404)` on a 3xx or 4xx reply

`send`, like `get` and `post`, only returns 2xx replies; every other status is
thrown as a `StatusError` (`error.status`, `error.data`, `error.response`).
Redirects are followed by Dio first. Catch the error to read the reply.

## `TimeoutError: GET /me (receive timeout after 0:00:10.000000)`

A phase of the request ran out of time. `error.stage` says which one:
`connect` (the connection was not opened), `send` (the body was not sent in
time) or `receive` (the server did not answer or finish answering); `timeout`
is the limit that was exceeded. A timeout is never retried, because the
request may have reached the server. Set the limits on the client, and
`sendTimeout` on its `dio`:

```dart
final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.com/v1/'),
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 30),
);
client.dio.options.sendTimeout = const Duration(seconds: 30);
```

Without a limit there is no timeout. Catch it to offer a retry yourself:

```dart
on TimeoutError catch (error) {
  print('Timed out in the ${error.stage.name} stage.');
}
```

## A request was not retried

Retry only sends again when all of these hold: `retry:` is set; the method is in
`methods` (a `POST` or `PATCH` is not by default); the failure is a connection
error or a status in `statuses` (timeouts are never retried); the body is not a
`Stream`; the token is not cancelled; `attempts` is not used up; and any
`Retry-After` is not above `maxDelay`, in which case the response is returned
as is. A `Retry-After` in a format other than seconds or an RFC 1123 date is
ignored and the backoff is used.

## `CancelledError: GET /me (cancelled)` that nobody cancelled

Something cancelled it: a `latest:` key reused by a newer call (the reason is
`superseded by a newer call`), `cancel()` on the client or a group (this also
cancels the groups below it), or a `CancelToken` you passed. A cancellation is
not a failure (`isFailure` is false): ignore it with `isCancelled(error)`. Use
a distinct `latest` key for calls that are not meant to replace each other.

## A header shows `[redacted]` in the logs

`HttpLogger` always replaces the value of `authorization`,
`proxy-authorization`, `cookie`, `set-cookie` and `x-api-key` in request and
response headers. `redact` adds names; the default set cannot be reduced.
Bodies and query strings are never redacted.

## The logger prints nothing

Errors thrown by the `sink` are swallowed on purpose, so a bug in it looks like
silence. Call the sink by hand with a record to see the exception, or wrap its
body in a `try`/`catch` that prints. An async sink whose future rejects is not
caught and surfaces as an unhandled error instead. Also check that the logger
is on the Dio that makes the call: `ApiClient(logger: ...)` or
`dio.interceptors.add(...)`, and that `ApiClient.wrap` was not given a Dio
without it.
