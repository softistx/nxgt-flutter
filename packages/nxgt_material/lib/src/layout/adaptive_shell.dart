import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/layout/shell_destination.dart';
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
/// It builds a [Scaffold]; keep the app bar of each screen in the [body] or
/// give the shell a [title] for a shared one.
class AdaptiveShell extends StatefulWidget {
  /// Creates an AdaptiveShell.
  const new({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.compactNavigation = CompactNavigation.bar,
    this.title,
    this.floatingActionButton,
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

  /// The title of a shared app bar; without it the shell has no app bar,
  /// except in [CompactNavigation.drawer], whose menu button needs one.
  final Widget? title;

  /// A floating action button over the body.
  final Widget? floatingActionButton;

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
    _report();
  }

  @override
  void didUpdateWidget(AdaptiveShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinations.length != widget.destinations.length ||
        oldWidget.selectedIndex != widget.selectedIndex) {
      _report();
    }
  }

  void _report() {
    final count = widget.destinations.length;
    if (!_usable) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError.fromParts([
            ErrorSummary('AdaptiveShell needs at least two destinations.'),
            ErrorDescription('It was given $count.'),
            ErrorHint(
              'Navigation bars and rails need two or more places; the body is '
              'shown without navigation until there are.',
            ),
          ]),
          library: 'nxgt_material',
          context: ErrorDescription('while building an AdaptiveShell'),
        ),
      );
    } else if (widget.selectedIndex < 0 || widget.selectedIndex >= count) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError.fromParts([
            ErrorSummary('AdaptiveShell.selectedIndex is out of range.'),
            ErrorDescription(
              'It was ${widget.selectedIndex} for $count destinations.',
            ),
            ErrorHint(
              'Use an index from 0 to ${count - 1}; the nearest one is '
              'selected meanwhile.',
            ),
          ]),
          library: 'nxgt_material',
          context: ErrorDescription('while building an AdaptiveShell'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = context.windowSize;
    if (!_usable) {
      return Scaffold(
        appBar: widget.title == null ? null : AppBar(title: widget.title),
        body: SafeArea(child: widget.body),
        floatingActionButton: widget.floatingActionButton,
      );
    }
    final drawer =
        size == WindowSize.compact &&
        widget.compactNavigation == CompactNavigation.drawer;
    final bar = size == WindowSize.compact && !drawer;
    final wide = size.isAtLeast(WindowSize.expanded);
    final rail = size == WindowSize.medium;
    final side = rail || wide;
    final hasAppBar = widget.title != null || drawer;
    final l10n = context.materialL10n;

    final body = Expanded(
      child: SafeArea(
        top: !hasAppBar,
        bottom: !bar,
        left: !side,
        child: widget.body,
      ),
    );

    return Scaffold(
      key: _scaffold,
      appBar: hasAppBar
          ? AppBar(
              title: widget.title,
              leading: drawer
                  ? IconButton(
                      tooltip: l10n.layoutOpenNavigation,
                      icon: const Icon(Icons.menu),
                      onPressed: () => _scaffold.currentState?.openDrawer(),
                    )
                  : null,
            )
          : null,
      drawer: drawer ? _buildDrawer(l10n.layoutCloseNavigation) : null,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: bar ? _buildBar(l10n.layoutNavigation) : null,
      body: side
          ? Row(
              children: [
                if (rail)
                  _buildRail(l10n.layoutNavigation)
                else
                  _buildStandardDrawer(l10n.layoutNavigation),
                body,
              ],
            )
          : Column(children: [body]),
    );
  }

  Widget _group(String label, Widget child) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: label,
    child: FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: child,
    ),
  );

  Widget _buildBar(String label) => _group(
    label,
    NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: widget.onSelected,
      destinations: [
        for (final d in widget.destinations)
          NavigationDestination(
            icon: _badged(d, d.icon),
            selectedIcon: _badged(d, d.selectedIcon ?? d.icon),
            label: d.label,
          ),
      ],
    ),
  );

  Widget _buildRail(String label) => _group(
    label,
    SafeArea(
      right: false,
      child: NavigationRail(
        selectedIndex: _index,
        onDestinationSelected: widget.onSelected,
        labelType: NavigationRailLabelType.all,
        destinations: [
          for (final d in widget.destinations)
            NavigationRailDestination(
              icon: _badged(d, d.icon),
              selectedIcon: _badged(d, d.selectedIcon ?? d.icon),
              label: Text(d.label),
            ),
        ],
      ),
    ),
  );

  Widget _buildStandardDrawer(String label) => _group(
    label,
    SafeArea(
      right: false,
      child: SizedBox(
        width: 280,
        child: NavigationDrawer(
          elevation: 0,
          selectedIndex: _index,
          onDestinationSelected: widget.onSelected,
          children: [..._drawerDestinations(), const SizedBox(height: 12)],
        ),
      ),
    ),
  );

  Widget _buildDrawer(String closeLabel) => NavigationDrawer(
    selectedIndex: _index,
    onDestinationSelected: (i) {
      Navigator.of(context).maybePop();
      widget.onSelected(i);
    },
    children: [
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: IconButton(
            tooltip: closeLabel,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      ..._drawerDestinations(),
    ],
  );

  List<Widget> _drawerDestinations() => [
    for (final d in widget.destinations)
      NavigationDrawerDestination(
        icon: _badged(d, d.icon),
        selectedIcon: _badged(d, d.selectedIcon ?? d.icon),
        label: Text(d.label),
      ),
  ];

  Widget _badged(ShellDestination d, Widget icon) => d.badge == null
      ? icon
      : Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            PositionedDirectional(top: -4, end: -6, child: d.badge!),
          ],
        );
}
