# Getting started

`nxgt_http` is a small client on top of [Dio](https://pub.dev/packages/dio).
It adds typed errors, token refresh, safe retries, redacted logging and
cancellation, and works on the Dart VM, Flutter and the web.

## Install

```sh
dart pub add nxgt_http
```

## Make a client

Create one client per backend and share it.

```dart
import 'package:nxgt_http/nxgt_http.dart';

final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.com/v1/'), // keep the trailing slash
  headers: {'accept-language': 'fr'}, // null values are left out
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 30),
);
```

## Call it

`get`, `post`, `put`, `patch` and `delete` return the decoded body. Without
`decode` the JSON body is cast to the type you ask for; with it you build your
own model.

```dart
final me = await client.get('/me', decode: User.fromJson);

final created = await client.post(
  '/users',
  data: {'name': 'Ada'},
  decode: User.fromJson,
);

final names = await client.get<List<Object?>>('/names', query: {'page': 2});
```

`decode` takes the JSON (`Map`, `List`, scalar or null) and returns a `T`. If it
throws, the call fails with a `DecodeError`.

## Read the status and headers

Use `send` to get an `ApiResponse<T>` with `data`, `statusCode` and `headers`:

```dart
final response = await client.send<User>(
  'POST',
  '/users',
  data: {'name': 'Ada'},
  decode: User.fromJson,
);

final location = response.headers.value('location');
print('${response.statusCode} $location ${response.data.name}');
```

## Handle failures

Every failure is thrown as a sealed `ApiError`. See the
[errors guide](errors.md).

```dart
try {
  await client.get<Object?>('/me');
} on ApiError catch (error) {
  print(error);
}
```

## Add the rest

Each feature is an option of the same constructor:

```dart
final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.com/v1/'),
  auth: AuthOptions(token: () => session.accessToken, refresh: session.renew),
  retry: const RetryOptions(),
  logger: HttpLogger(sink: (record) => print(record)),
);
```

- [Authentication](auth.md): bearer token and refresh on a 401.
- [Retry](retry.md): safe, jittered, `Retry-After` aware.
- [Logging](logging.md): one redacted record per attempt.
- [Cancelling](cancelling.md): one call, or all of a screen's calls.

## Use an existing Dio

`ApiClient.wrap(dio)` uses a Dio you configured yourself, and `client.dio`
gives access to the one in use, for example to add an interceptor.
