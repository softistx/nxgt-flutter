import 'package:flutter/material.dart';
import 'package:nxgt_material/src/actions/load_more_button.dart';
import 'package:nxgt_material/src/feedback/error_state.dart';
import 'package:nxgt_material/src/feedback/loading_state.dart';

/// What ends a `PagedList`, or `null` when nothing does: the inline failure
/// with its retry, the loading state, or the "Show more" button.
Widget? buildPagedListFooter({
  required bool failed,
  required Future<void> Function()? onRetry,
  required bool loading,
  required bool showButton,
  required Future<void> Function() onLoadMore,
}) {
  if (failed) return ErrorState(onRetry: onRetry);
  if (loading) return const LoadingState();
  if (showButton) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(child: LoadMoreButton(onPressed: onLoadMore)),
    );
  }
  return null;
}
