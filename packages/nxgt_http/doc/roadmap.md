# Roadmap

## Now

- **nxgt_http 0.1**: a dio client for Dart and Flutter apps, with typed errors,
  token refresh, safe retries, redacted logging and cancellation of a call or
  a whole screen's calls. Tracked in
  [#10](https://github.com/softistx/nxgt-flutter/issues/10).
  - Done on the integration branch: `ApiClient` (base URL, headers, timeouts,
    `wrap(Dio)`, `get`/`post`/`put`/`patch`/`delete` with `decode`) and the
    sealed `ApiError`, auth with a shared token refresh (`AuthOptions`,
    `AuthInterceptor`), retry (`RetryOptions`, `RetryInterceptor`), redacted logging
    (`HttpLogger`), cancellation by group and `latest` key.
  - To come: `send` for status and headers.

## Next

## Later

- Cache, server-sent events, OpenAPI code generation.

## Shipped

Nothing yet.
