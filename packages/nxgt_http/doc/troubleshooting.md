# Troubleshooting

Entries are added as problems are found: the exact message, when, why, the fix.

## A call fails with `NetworkError` in the browser but works elsewhere

On the web, a request the browser blocks (CORS, mixed content) reaches the
client as a connection failure, so it is a `NetworkError` whose `cause` has no
status. Check the browser console for the blocked origin and allow it on the
server.

## `DecodeError` on a call that returned 200

The body arrived, but `decode` threw or the body is not of type `T`. The
original exception is in `error.cause` and its trace in `error.stackTrace`.
Pass a `decode` function for anything other than a raw JSON `Map` or `List`:

```dart
final user = await client.get('/me', decode: User.fromJson);
```

## A 401 is thrown even though `refresh` ran

`refresh` ran but `token` returned the same value (or null), so the request was
not replayed and the 401 is thrown. Make `refresh` store the new token where
`token` reads it, before it completes.

## A request was not retried

Retry only sends again when all of these hold: `retry:` is set; the method is in
`methods` (a `POST` or `PATCH` is not by default); the failure is a connection
error or a status in `statuses` (timeouts are never retried); the body is not a
`Stream`; the token is not cancelled; `attempts` is not used up; and any
`Retry-After` is not above `maxDelay`, in which case the response is returned
as is. A `Retry-After` in a format other than seconds or an RFC 1123 date is
ignored and the backoff is used.

## A call throws `CancelledError` that nobody cancelled

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
