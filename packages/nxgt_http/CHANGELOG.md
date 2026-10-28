## 0.1.0

First release.

- `ApiClient`: a Dio client with a base URL, default headers, `connectTimeout` and `receiveTimeout`. `get`, `post`, `put`, `patch` and `delete` return the decoded body; `send` returns an `ApiResponse<T>` (`data`, `statusCode`, `headers`). `Decode<T>` turns the JSON body into your type. `ApiClient.wrap(Dio)` keeps an existing `Dio`, and `client.dio` stays public.

- `ApiError`: a sealed class thrown for every failure, with `NetworkError`, `TimeoutError` (with `TimeoutStage`: connect, send, receive), `StatusError` (`status`, `data`, `response`), `DecodeError` and `CancelledError`. `ApiError.fromDio` maps a `DioException`, `isFailure` is false for a cancellation, and `isCancelled(error)` recognises one, typed or raw.

- `AuthOptions` and `AuthInterceptor`: a `token` callback adds the header; a 401 runs `refresh` once, shared by all concurrent calls, and replays the request. A failed refresh surfaces the original 401 as a `StatusError`.

- `RetryOptions` and `RetryInterceptor`: jittered backoff, `Retry-After` (seconds or date, capped by `maxDelay`), retries only idempotent methods by default, on a connection error or a configured status. Timeouts and cancelled calls are never retried.

- `HttpLogger` and `HttpLogRecord`: one record per attempt (method, URL, status, duration, error type) sent to a `sink`. The `authorization`, `proxy-authorization`, `cookie`, `set-cookie` and `x-api-key` headers are always redacted, `redact` adds names, and bodies are logged only with `bodies: true`.

- Cancellation: `client.group()` returns a client whose calls are cancelled together with `cancel([reason])`; `latest: 'key'` cancels the previous call with the same key.

- Interceptors run in this order: logger, auth, retry, then your own `interceptors`.
