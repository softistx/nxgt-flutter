import 'package:flutter/material.dart';
import 'package:nxgt_material/src/layout/window_size.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';

/// A list and its detail side by side, or one at a time on a narrow space.
///
/// When the layout is wider than [Breakpoints.singlePane] (648 dp, as
/// `ListDetailsLayout` of `@nxgt/material`) both panes show: the [list] at
/// [listWidth] and the [detail] filling the rest. Narrower, only one shows:
/// the [detail] while [showDetail] is true, the [list] otherwise, and the
/// system back gesture calls [onBack] so the app can clear its selection and
/// return to the list. It follows its own width, not the window's, so it also
/// works in a column or a dialog.
class ListDetailLayout extends StatelessWidget {
  /// Creates a ListDetailLayout.
  const new({
    required this.list,
    required this.detail,
    required this.showDetail,
    this.onBack,
    this.listWidth = 360,
    super.key,
  });

  /// The list pane.
  final Widget list;

  /// The detail pane.
  final Widget detail;

  /// Whether the detail is the current view when only one pane fits.
  final bool showDetail;

  /// Called when the user goes back from the detail on a narrow layout.
  final VoidCallback? onBack;

  /// The width of the list pane when both show.
  final double listWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > Breakpoints.singlePane) {
          return Row(
            children: [
              SizedBox(
                width: listWidth,
                child: Semantics(container: true, child: list),
              ),
              Expanded(child: _DetailPane(child: detail)),
            ],
          );
        }
        return PopScope(
          canPop: !(showDetail && onBack != null),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) onBack?.call();
          },
          child: showDetail
              ? Semantics(container: true, child: detail)
              : Semantics(container: true, child: list),
        );
      },
    );
  }
}

class _DetailPane extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8, top: 8, bottom: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(context.radii.lg),
        child: Semantics(container: true, child: child),
      ),
    );
  }
}
