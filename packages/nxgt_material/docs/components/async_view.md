# AsyncView

Library: `package:nxgt_material/feedback.dart`

Shows the right state for asynchronous data: [LoadingState](loading_state.md)
while it loads, [ErrorState](error_state.md) when it failed,
[EmptyState](empty_state.md) when it is empty, and your `builder` once it has
data.

## When to use it

Instead of a hand-written `FutureBuilder` that checks `hasError`, `hasData` and
emptiness on every screen. Give it a `future`, or a `snapshot` you already hold
(from a `StreamBuilder`, a bloc, a provider); exactly one of the two.

## Example

```dart
AsyncView<List<Invoice>>(
  future: repository.invoices(),
  isEmpty: (invoices) => invoices.isEmpty,
  onRetry: () async => setState(() => future = repository.invoices()),
  builder: (context, invoices) => InvoiceList(invoices),
)
```

With a snapshot:

```dart
AsyncView<int>(snapshot: snapshot, builder: (context, n) => Text('$n'))
```

A snapshot with an error shows the `ErrorState` with its default copy: the
exception is never displayed. A finished snapshot with no data counts as empty
unless `T` is nullable (`AsyncView<void>` shows `builder` once done).

## Accessibility

Each state is a live region (see the pages above), so every change of state is
announced; the content you build is yours to label.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `builder` | `Widget Function(BuildContext, T)` | Builds the content once data arrived and is not empty. |
| `future` | `Future<T>?` | The data to wait for. |
| `snapshot` | `AsyncSnapshot<T>?` | A snapshot held by the caller. |
| `isEmpty` | `bool Function(T)?` | Tells whether the data is empty; `null` means never. |
| `empty` | `Widget?` | Replaces the default `EmptyState`. |
| `onRetry` | `Future<void> Function()?` | Retry of the `ErrorState`; `null` hides the button. |
