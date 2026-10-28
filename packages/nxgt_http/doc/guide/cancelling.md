# Cancelling

Three tools, from one call to a whole screen. A cancelled call throws a
`CancelledError`, whose `isFailure` is `false`: it is not a failure to report.

## A whole screen: `group()`

`group()` returns a client that shares the Dio and the interceptors of its
parent. Its `cancel` stops all the calls it made.

```dart
class UserPage {
  UserPage(ApiClient api) : _api = api.group();
  final ApiClient _api;

  Future<User> load() => _api.get('/me', decode: User.fromJson);
  Future<List<Post>> posts() => _api.get('/posts', decode: Post.listFromJson);

  void dispose() => _api.cancel('page closed');
}
```

- Cancelling a group does not touch its parent or its sibling groups.
- **Cancelling the parent cancels the calls of all its groups**, so
  `client.cancel()` stops everything in flight (on sign-out, for example).
- A group stays usable after `cancel`; its next call starts normally.
- Nothing is registered in the parent for the group itself, and a call leaves
  the books when it ends: neither a finished call nor a dropped group is kept.

## Search as you type: `latest`

`latest: 'key'` cancels the previous in-flight call of the same client with the
same key. Only the last answer matters.

```dart
Future<List<City>> search(String text) =>
    _api.get('/cities', query: {'q': text}, latest: 'cities', decode: City.list);
```

The superseded call throws `CancelledError` with the reason
`superseded by a newer call`. Keys are per client or group: two groups can use
the same key without affecting each other.

## Handling a cancellation

```dart
try {
  results = await search(text);
} on Object catch (error) {
  if (isCancelled(error)) return; // a newer call or a closed screen
  rethrow;
}
```

The reason you gave to `cancel` is on the error:

```dart
} on CancelledError catch (error) {
  print(error.reason); // 'page closed'
}
```

`isCancelled` accepts a `CancelledError` and a raw `DioException` of type
`cancel`. With `on ApiError`, test `error.isFailure` or switch on
`CancelledError`.

## Your own `CancelToken`

Every call method still takes `cancelToken`. The call runs on its own token
that follows yours, so cancelling yours cancels the call with your reason.
A tiny listener closure stays on a long-lived token until it is cancelled, but
it holds no token: it refers to the call's token weakly and does nothing once
the call has finished.

## After a cancel

Nothing more is sent. A cancelled request is not retried (a pending retry wait
ends at once) and an expired token is not refreshed for it.
