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
/// works in a column or a dialog, and needs a bounded width.
///
/// Both panes keep their state (scroll position, text being typed) when the
/// layout crosses 648 dp, and the hidden pane of a narrow layout stays alive
/// but is neither focusable nor read by screen readers. Two side effects:
/// the hidden pane stays built, so its `initState` work (fetches) still runs
/// and a detail builder runs with no selection; and two panes cannot both use
/// the `PrimaryScrollController`, so give one of their scroll views a
/// controller of its own.
class ListDetailLayout extends StatefulWidget {
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
  State<ListDetailLayout> createState() => _ListDetailLayoutState();
}

class _ListDetailLayoutState extends State<ListDetailLayout> {
  final GlobalKey _listKey = GlobalKey();
  final GlobalKey _detailKey = GlobalKey();

  Widget _hideable(Widget child, {required bool hidden}) => Offstage(
    offstage: hidden,
    child: TickerMode(
      enabled: !hidden,
      child: ExcludeFocus(excluding: hidden, child: child),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final list = KeyedSubtree(key: _listKey, child: widget.list);
    final detail = KeyedSubtree(key: _detailKey, child: widget.detail);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > Breakpoints.singlePane;
        final back = !wide && widget.showDetail && widget.onBack != null;
        return PopScope(
          canPop: !back,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) widget.onBack?.call();
          },
          child: wide
              ? Row(
                  children: [
                    SizedBox(
                      width: widget.listWidth,
                      child: Semantics(container: true, child: list),
                    ),
                    Expanded(child: _DetailPane(child: detail)),
                  ],
                )
              : Stack(
                  fit: StackFit.passthrough,
                  children: [
                    _hideable(
                      Semantics(container: true, child: list),
                      hidden: widget.showDetail,
                    ),
                    _hideable(
                      Semantics(container: true, child: detail),
                      hidden: !widget.showDetail,
                    ),
                  ],
                ),
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
