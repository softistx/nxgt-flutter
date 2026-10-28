import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/layout/safe_sides.dart';
import 'package:nxgt_material/src/layout/shell_destination.dart';
import 'package:nxgt_material/src/layout/shell_navigation.dart';
import 'package:nxgt_material/src/layout/shell_validation.dart';
import 'package:nxgt_material/src/layout/window_size.dart';

/// The frame of an app: its [destinations] as a navigation bar, a rail or a
/// drawer, whichever the window's size asks for.
///
/// - [WindowSize.compact]: a `NavigationBar` at the bottom, or with
///   [compactNavigation] set to [CompactNavigation.drawer] a modal
///   `NavigationDrawer` opened by an app bar button (labelled "Open
///   navigation") and closed by its own button ("Close navigation").
/// - [WindowSize.medium]: a `NavigationRail` with its labels.
/// - [WindowSize.expanded] and wider: a standard `NavigationDrawer`, always
///   visible beside the body (Material's extended rail has destinations only
///   44 dp tall, under the 48 dp target).
///
/// The [body] stays in place when the window changes class, and the system
/// insets (notch, home indicator, display cut-outs) are kept off the
/// navigation and the body. The destinations take keyboard focus in reading
/// order (Tab moves through them, Enter or Space selects) and highlight under
/// a mouse pointer, as Material's own destinations do.
///
/// It builds a [Scaffold]: give it a [title] (or an [appBar]) for a shared app
/// bar, or keep an app bar in each screen. A screen's own `Scaffold` can nest
/// inside [body]. The [body] keeps its state when the window changes class,
/// and an open drawer closes when the window leaves the compact class.
class AdaptiveShell extends StatefulWidget {
  /// Creates an AdaptiveShell.
  const new({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.compactNavigation = CompactNavigation.bar,
    this.title,
    this.appBar,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomSheet,
    super.key,
  });

  /// The places of the app, at least two.
  final List<ShellDestination> destinations;

  /// The index of the current destination.
  final int selectedIndex;

  /// Called with the index of the destination the user picked.
  final ValueChanged<int> onSelected;

  /// The current screen.
  final Widget body;

  /// What a compact window uses: a bar (default) or a drawer.
  final CompactNavigation compactNavigation;

  /// The title of a shared app bar; without it (and without [appBar]) the
  /// shell has no app bar, except in [CompactNavigation.drawer], whose menu
  /// button needs one.
  final Widget? title;

  /// A shared app bar of your own; it replaces the one built from [title] and
  /// [actions]. With [CompactNavigation.drawer] the `AppBar` adds Material's
  /// drawer button on its own, unless you set its `leading`.
  final PreferredSizeWidget? appBar;

  /// Actions of the app bar built from [title].
  final List<Widget>? actions;

  /// A floating action button over the body.
  final Widget? floatingActionButton;

  /// Where the floating action button sits.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// A persistent bottom sheet, as `Scaffold.bottomSheet`.
  final Widget? bottomSheet;

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  final _scaffold = GlobalKey<ScaffoldState>();

  bool get _usable => widget.destinations.length >= 2;

  int get _index => widget.selectedIndex.clamp(
    0,
    widget.destinations.isEmpty ? 0 : widget.destinations.length - 1,
  );

  @override
  void initState() {
    super.initState();
    reportShellProblems(widget.destinations, widget.selectedIndex);
  }

  @override
  void didUpdateWidget(AdaptiveShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinations.length != widget.destinations.length ||
        oldWidget.selectedIndex != widget.selectedIndex) {
      reportShellProblems(widget.destinations, widget.selectedIndex);
    }
  }

  PreferredSizeWidget? _appBar(bool drawer, bool compact, String openLabel) {
    if (widget.appBar != null) return widget.appBar;
    if (widget.title == null && !drawer) return null;
    return AppBar(
      title: widget.title,
      actions: widget.actions,
      automaticallyImplyLeading: compact,
      leading: drawer
          ? IconButton(
              tooltip: openLabel,
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffold.currentState?.openDrawer(),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = context.windowSize;
    if (!_usable) {
      return Scaffold(
        appBar:
            widget.appBar ??
            (widget.title == null
                ? null
                : AppBar(title: widget.title, actions: widget.actions)),
        body: SafeArea(child: widget.body),
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        bottomSheet: widget.bottomSheet,
      );
    }
    final compact = size == WindowSize.compact;
    final drawer =
        compact && widget.compactNavigation == CompactNavigation.drawer;
    final bar = compact && !drawer;
    final rail = size == WindowSize.medium;
    final standing = size.isAtLeast(WindowSize.expanded);
    final l10n = context.materialL10n;
    final appBar = _appBar(drawer, compact, l10n.layoutOpenNavigation);
    final data = ShellNavigationData(
      destinations: widget.destinations,
      selectedIndex: _index,
      onSelected: widget.onSelected,
      label: l10n.layoutNavigation,
    );

    if (!drawer && (_scaffold.currentState?.isDrawerOpen ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final scaffold = _scaffold.currentState;
        if (mounted && (scaffold?.isDrawerOpen ?? false)) {
          scaffold!.closeDrawer();
        }
      });
    }

    // One Row for every size class, the navigation in its first slot, so the
    // body keeps its place in the tree (and its state) when the class changes.
    return Scaffold(
      key: _scaffold,
      appBar: appBar,
      drawer: widget.compactNavigation == CompactNavigation.drawer
          ? buildShellModalDrawer(context, data, l10n.layoutCloseNavigation)
          : null,
      drawerEnableOpenDragGesture: drawer,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomSheet: widget.bottomSheet,
      bottomNavigationBar: bar ? buildShellBar(data) : null,
      body: Row(
        children: [
          if (rail)
            buildShellRail(data)
          else if (standing)
            buildShellStandardDrawer(data)
          else
            const SizedBox.shrink(),
          Expanded(
            child: SafeSides(
              start: !rail && !standing,
              top: appBar == null,
              bottom: !bar,
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
