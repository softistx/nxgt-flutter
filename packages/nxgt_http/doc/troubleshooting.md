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
