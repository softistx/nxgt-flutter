import 'dart:async';

import 'package:dio/dio.dart';

/// The in-flight calls of one client or group; ancestors see them too.
/// Library-private: not exported. Tokens are removed when their call ends, so
/// nothing accumulates.
class CallScope {
  /// Creates a scope below [parent] (none for a root client).
  new(this.parent);

  /// The scope of the client this group came from.
  final CallScope? parent;

  /// Tokens of the calls in flight in this scope and its groups.
  final Set<CancelToken> tokens = {};

  /// The in-flight token of each `latest` key.
  final Map<String, CancelToken> latest = {};

  static const _superseded = 'superseded by a newer call';

  /// Registers a call and returns the token it must run on. [user] is the
  /// caller's own token, which cancels the call; [key] is its `latest` key.
  CancelToken start(CancelToken? user, String? key) {
    final token = CancelToken();
    if (user != null) {
      if (user.isCancelled) {
        token.cancel(user.cancelError?.error);
      } else {
        // Holds the internal token weakly and does nothing once the call has
        // finished, so a long-lived caller token keeps no token alive.
        final ref = WeakReference(token);
        unawaited(
          user.whenCancel.then((e) {
            final target = ref.target;
            if (target != null && tokens.contains(target)) {
              target.cancel(e.error);
            }
          }),
        );
      }
    }
    if (key != null) latest.remove(key)?.cancel(_superseded);
    if (key != null) latest[key] = token;
    for (CallScope? s = this; s != null; s = s.parent) {
      s.tokens.add(token);
    }
    return token;
  }

  /// Releases a call's token once it has ended.
  void finish(CancelToken token, String? key) {
    if (key != null && identical(latest[key], token)) latest.remove(key);
    for (CallScope? s = this; s != null; s = s.parent) {
      s.tokens.remove(token);
    }
  }
}
