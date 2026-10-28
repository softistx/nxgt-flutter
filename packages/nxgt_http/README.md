# nxgt_http

A typed HTTP client for Dart on Dio: sealed errors, auth, retry and logging.
Pure Dart: it runs on the Dart VM, Flutter and the web.

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
} on ApiError catch (error) {
  switch (error) {
    case StatusError(:final status): // the server answered 4xx or 5xx
    case TimeoutError(:final stage): // connect, send or receive
    case NetworkError(): // no answer at all
    case DecodeError(): // the body is not what `decode` expects
    case CancelledError(): // not a failure: `isFailure` is false
  }
}
```

Every failure is thrown as an `ApiError`; there is no result type. To keep an
existing `Dio`, use `ApiClient.wrap(dio)`; the underlying `client.dio` stays
public.

## Documentation

- [Roadmap](doc/roadmap.md)
- [Troubleshooting](doc/troubleshooting.md)

## License

MIT, see [LICENSE](LICENSE).
