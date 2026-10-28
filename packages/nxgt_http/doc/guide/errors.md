# Errors

Every call method throws an `ApiError` and nothing else for a transport,
status, decoding or cancellation problem. There is no result type.

`ApiError` is a sealed class, so a `switch` over it is checked for
exhaustiveness. Each error carries `method`, `path`, `cause` (the underlying
exception, if any) and `stackTrace`.

| Type | When | Extra fields |
| --- | --- | --- |
| `NetworkError` | no answer: no connection, DNS, TLS, CORS in a browser, or your `token` callback threw | |
| `TimeoutError` | connect, send or receive timeout | `timeout`, `stage` (`connect`, `send`, `receive`) |
| `StatusError` | the server answered with a non-2xx status | `status`, `data` (decoded body), `response` |
| `DecodeError` | the body arrived but `decode` threw or the type did not match | |
| `CancelledError` | the call was cancelled | `reason`; `isFailure` is `false` |

## Switch on it

```dart
try {
  final user = await client.get('/me', decode: User.fromJson);
  show(user);
} on ApiError catch (error) {
  switch (error) {
    case StatusError(status: 401):
      goToSignIn();
    case StatusError(:final status, :final data) when status >= 500:
      showMessage('Server error $status', details: data);
    case StatusError(:final data):
      showMessage('Rejected: $data');
    case TimeoutError(:final stage):
      showMessage('Too slow (${stage.name}). Try again.');
    case NetworkError():
      showMessage('You seem to be offline.');
    case DecodeError(:final cause):
      report(cause, error.stackTrace);
    case CancelledError():
      break; // not a failure
  }
}
```

## Cancellations

A `CancelledError` is what you get when you cancel on purpose, so
`isFailure` is `false`. When you only want to ignore it, use `isCancelled`,
which also recognises Dio's own cancel exception:

```dart
try {
  await client.get<Object?>('/cities', query: {'q': text}, latest: 'search');
} on Object catch (error) {
  if (!isCancelled(error)) rethrow;
}
```

## Reading the server's error body

For a `StatusError`, `data` is the decoded JSON body and `response` is the full
Dio response (headers included):

```dart
on StatusError catch (error) {
  final message = (error.data as Map<String, Object?>?)?['message'];
  final retryAfter = error.response.headers.value('retry-after');
}
```

## Mapping a Dio exception

`ApiError.fromDio(DioException)` does the mapping the client uses. It helps when
you call `client.dio` directly or write an interceptor.

An interceptor can also reject with a `DioException` whose `error` is an
`ApiError`; the client then throws that error as is.
