import 'dart:async';

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
///
/// **Keep the [future] in state** (`initState`, a controller, a provider),
/// never create it inline in `build`: a new future restarts the load on every
/// rebuild.
///
/// A failed [future] is reported once with [FlutterError.reportError]. With a
/// [snapshot] the caller owns the reporting: the view only shows the error.
class AsyncView<T> extends StatefulWidget {
  /// Creates an AsyncView over a [future] or a [snapshot].
  const new({
    required this.builder,
    this.future,
    this.snapshot,
    this.isEmpty,
    this.empty,
    this.errorBuilder,
    this.onRetry,
    super.key,
  }) : assert(
         (future == null) != (snapshot == null),
         'Give AsyncView either a future or a snapshot, not both or neither.',
       );

  /// The data to wait for. The view follows it; a new future restarts the
  /// load. Keep it in state, not inline in `build`.
  final Future<T>? future;

  /// A snapshot held by the caller, read as is. Its error is shown, not
  /// reported.
  final AsyncSnapshot<T>? snapshot;

  /// Builds the content once the data has arrived and is not empty.
  final Widget Function(BuildContext context, T data) builder;

  /// Tells whether the data is empty (an empty list, say). `null` means the
  /// data is never empty.
  final bool Function(T data)? isEmpty;

  /// Shown instead of the default [EmptyState] when the data is empty.
  final Widget? empty;

  /// Builds the failure state; defaults to an [ErrorState] with [onRetry].
  /// Use it to word the message for a known error.
  final Widget Function(BuildContext context, Object error, StackTrace? stack)?
  errorBuilder;

  /// Runs the retry of the default [ErrorState]; `null` shows no retry button.
  /// Ignored when [errorBuilder] is given.
  final Future<void> Function()? onRetry;

  @override
  State<AsyncView<T>> createState() => _AsyncViewState<T>();
}

class _AsyncViewState<T> extends State<AsyncView<T>> {
  @override
  void initState() {
    super.initState();
    _report(widget.future);
  }

  @override
  void didUpdateWidget(AsyncView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.future != oldWidget.future) _report(widget.future);
  }

  // Once per future, outside `build`; a future that was replaced before it
  // failed is not reported.
  void _report(Future<T>? future) {
    unawaited(
      future?.then<void>(
        (_) {},
        onError: (Object error, StackTrace stack) {
          if (!mounted || widget.future != future) return;
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stack,
              library: 'nxgt_material',
              context: ErrorDescription(
                'while loading the data of an AsyncView',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final future = widget.future;
    if (future != null) {
      return FutureBuilder<T>(future: future, builder: _state);
    }
    return _state(context, widget.snapshot!);
  }

  Widget _state(BuildContext context, AsyncSnapshot<T> snapshot) {
    if (snapshot.hasError) {
      final errorBuilder = widget.errorBuilder;
      return errorBuilder == null
          ? ErrorState(onRetry: widget.onRetry)
          : errorBuilder(context, snapshot.error!, snapshot.stackTrace);
    }
    final done = snapshot.connectionState == ConnectionState.done;
    if (!snapshot.hasData && !done) return const LoadingState();
    final empty = widget.empty ?? const EmptyState();
    if (!snapshot.hasData && null is! T) return empty;
    final data = snapshot.data as T;
    if (widget.isEmpty?.call(data) ?? false) return empty;
    return widget.builder(context, data);
  }
}
