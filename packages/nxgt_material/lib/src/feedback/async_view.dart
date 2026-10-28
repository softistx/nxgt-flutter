import 'package:flutter/material.dart';
import 'package:nxgt_material/src/feedback/empty_state.dart';
import 'package:nxgt_material/src/feedback/error_state.dart';
import 'package:nxgt_material/src/feedback/loading_state.dart';

/// Shows the right state for asynchronous data: a [LoadingState] while it
/// loads, an [ErrorState] (with a retry) when it failed, an [EmptyState] when
/// it is empty, and [builder] once it has data.
///
/// Give it either a [future] or a [snapshot] you already hold (from a
/// `StreamBuilder`, a bloc, a provider); exactly one of the two. Prefer it to
/// a hand-written `FutureBuilder` that checks `hasError`, `hasData` and
/// emptiness by hand on every screen.
class AsyncView<T> extends StatelessWidget {
  /// Creates an AsyncView over a [future] or a [snapshot].
  const new({
    required this.builder,
    this.future,
    this.snapshot,
    this.isEmpty,
    this.empty,
    this.onRetry,
    super.key,
  }) : assert(
         (future == null) != (snapshot == null),
         'Give AsyncView either a future or a snapshot, not both or neither.',
       );

  /// The data to wait for. The view follows it; a new future restarts the
  /// load.
  final Future<T>? future;

  /// A snapshot held by the caller, read as is.
  final AsyncSnapshot<T>? snapshot;

  /// Builds the content once the data has arrived and is not empty.
  final Widget Function(BuildContext context, T data) builder;

  /// Tells whether the data is empty (an empty list, say). `null` means the
  /// data is never empty.
  final bool Function(T data)? isEmpty;

  /// Shown instead of the default [EmptyState] when the data is empty.
  final Widget? empty;

  /// Runs the retry of the [ErrorState]; `null` shows no retry button.
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final future = this.future;
    if (future != null) {
      return FutureBuilder<T>(future: future, builder: _state);
    }
    return _state(context, snapshot!);
  }

  Widget _state(BuildContext context, AsyncSnapshot<T> snapshot) {
    if (snapshot.hasError) return ErrorState(onRetry: onRetry);
    final done = snapshot.connectionState == ConnectionState.done;
    if (!snapshot.hasData && !done) return const LoadingState();
    if (!snapshot.hasData && null is! T) return empty ?? const EmptyState();
    final data = snapshot.data as T;
    if (isEmpty?.call(data) ?? false) return empty ?? const EmptyState();
    return builder(context, data);
  }
}
