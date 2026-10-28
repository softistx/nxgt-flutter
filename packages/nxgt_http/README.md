# nxgt_http

A typed HTTP client for Dart on Dio with sealed errors. Logging is on the [roadmap](doc/roadmap.md). Pure Dart: it
runs on the Dart VM, Flutter and the web.

## Install

```sh
dart pub add nxgt_http
```

## Use

```dart
import 'package:nxgt_http/nxgt_http.dart';

final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.com/v1/'),
  headers: {'accept-language': 'fr'},
  connectTimeout: const Duration(seconds: 10),
);

try {
  final user = await client.get('/me', decode: User.fromJson);
  print(user.name);
} on ApiError catch (error) {
  switch (error) {
    case StatusError(:final status):
      print('The server answered $status.');
    case TimeoutError(:final stage):
      print('Timed out while trying to ${stage.name}.');
    case NetworkError():
      print('No answer at all.');
    case DecodeError():
      print('The body is not what decode expects.');
    case CancelledError():
      print('Cancelled: not a failure.');
  }
}
```

Every failure is thrown as an `ApiError`; there is no result type.
`ApiError.fromDio(DioException)` maps a Dio exception to its typed error. To keep an
existing `Dio`, use `ApiClient.wrap(dio)`; the underlying `client.dio` stays
public.

## Authentication

```dart
final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.com/v1/'),
  auth: AuthOptions(
    token: () => session.accessToken,
    refresh: () async => session.renew(),
  ),
);
```

A 401 refreshes the token once, shared by all concurrent calls, and replays the
request. See the [authentication guide](doc/guide/auth.md).

## Retry

```dart
final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.com/v1/'),
  retry: const RetryOptions(),
);
```

`GET`, `HEAD`, `OPTIONS`, `PUT` and `DELETE` are sent again on a connection
error or a 408, 429, 502, 503 or 504, with a jittered backoff and `Retry-After`.
See the [retry guide](doc/guide/retry.md).

## Documentation

- [Authentication](doc/guide/auth.md)
- [Retry](doc/guide/retry.md)
- [Roadmap](doc/roadmap.md)
- [Troubleshooting](doc/troubleshooting.md)

## License

MIT, see [LICENSE](LICENSE).
