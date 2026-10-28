import 'package:flutter/material.dart';
import 'package:nxgt_material/src/actions/async_button.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// The "Show more" button at the end of a paginated list.
///
/// It is an outlined [AsyncButton]: it shows a spinner while [onPressed]
/// loads the next page, and disappears once [hasMore] is false. Prefer it to a
/// hand-made button under a list with cursor pagination.
class LoadMoreButton extends StatelessWidget {
  /// Creates a LoadMoreButton.
  const new({
    required this.onPressed,
    this.hasMore = true,
    this.label,
    super.key,
  });

  /// Loads the next page; the button is busy until the future completes.
  final Future<void> Function() onPressed;

  /// Whether another page exists. When false nothing is built.
  final bool hasMore;

  /// The text shown; defaults to the localized "Show more".
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) return const SizedBox.shrink();
    return AsyncButton(
      label: label ?? context.materialL10n.actionsShowMore,
      onPressed: onPressed,
      variant: AsyncButtonVariant.outlined,
    );
  }
}
