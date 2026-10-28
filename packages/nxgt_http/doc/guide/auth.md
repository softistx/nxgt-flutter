# Authentication

`AuthOptions` gives the client two callbacks; it never stores a token itself.

```dart
final client = ApiClient(
  baseUrl: Uri.parse('https://api.example.com/v1/'),
  auth: AuthOptions(
    token: () => session.accessToken,
    refresh: () async => session.renew(), // store the new token for `token`
  ),
);
```

- `token` is read before every request and sent as `Authorization: Bearer <token>`
  (`scheme` changes `Bearer`). A null or empty token sends no header. An
  `Authorization` header you set on a call is kept.
- `refresh` is called when the server answers 401. The request is then replayed
  once with the new token.

## What a 401 does

- **Concurrent 401s share one refresh.** Ten calls failing together run
  `refresh` once and are all replayed.
- **A call that sent an out-of-date token** (its 401 arrives after another call
  already refreshed) is replayed without a second refresh.
- **No loop.** A replayed request is marked and never refreshed again: a 401 on
  the replay is thrown as a `StatusError`.
- **A failed refresh** (it throws, or the token is unchanged afterwards) throws
  the original 401 as a `StatusError` with `status == 401`. When `refresh`
  threw, its exception is the `error` of the `DioException` in `error.cause`.
  Use it to sign the user out:

```dart
try {
  await client.get<Object?>('/me');
} on StatusError catch (error) {
  if (error.status == 401) session.signOut();
}
```

- A call that carries its own `Authorization` header is never refreshed: its
  401 is thrown as is.
- When signed out (`token` returns null) a 401 also runs `refresh`, which can
  therefore restore a session.
- Without `refresh`, a 401 is thrown as is.
- A `FormData` body is cloned for the replay, since a stream is read once.

## On a plain Dio

```dart
final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'));
dio.interceptors.add(
  AuthInterceptor(
    AuthOptions(token: () => session.accessToken, refresh: session.renew),
    dio,
  ),
);
```

`ApiClient` places the auth interceptor first, before the `interceptors` you
pass.
