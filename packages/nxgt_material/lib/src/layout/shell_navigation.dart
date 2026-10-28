import 'package:flutter/material.dart';
import 'package:nxgt_material/src/layout/safe_sides.dart';
import 'package:nxgt_material/src/layout/shell_destination.dart';

/// What the navigation widgets of an `AdaptiveShell` share.
class ShellNavigationData {
  /// Creates a ShellNavigationData.
  const new({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.label,
  });

  /// The places.
  final List<ShellDestination> destinations;

  /// The selected index, already clamped.
  final int selectedIndex;

  /// Called with the picked index.
  final ValueChanged<int> onSelected;

  /// The label of the navigation region.
  final String label;
}

Widget _badged(ShellDestination d, Widget icon) => d.badge == null
    ? icon
    : Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          PositionedDirectional(top: -4, end: -6, child: d.badge!),
        ],
      );

Widget _group(String label, Widget child) => Semantics(
  container: true,
  explicitChildNodes: true,
  label: label,
  child: FocusTraversalGroup(
    policy: ReadingOrderTraversalPolicy(),
    child: child,
  ),
);

List<NavigationDrawerDestination> _drawerDestinations(
  List<ShellDestination> destinations,
) => [
  for (final d in destinations)
    NavigationDrawerDestination(
      icon: _badged(d, d.icon),
      selectedIcon: _badged(d, d.selectedIcon ?? d.icon),
      label: Text(d.label),
    ),
];

/// The bottom `NavigationBar` of a compact window.
Widget buildShellBar(ShellNavigationData data) => _group(
  data.label,
  NavigationBar(
    selectedIndex: data.selectedIndex,
    onDestinationSelected: data.onSelected,
    destinations: [
      for (final d in data.destinations)
        NavigationDestination(
          icon: _badged(d, d.icon),
          selectedIcon: _badged(d, d.selectedIcon ?? d.icon),
          label: d.label,
        ),
    ],
  ),
);

/// The `NavigationRail` of a medium window.
Widget buildShellRail(ShellNavigationData data) => _group(
  data.label,
  SafeSides(
    end: false,
    child: NavigationRail(
      selectedIndex: data.selectedIndex,
      onDestinationSelected: data.onSelected,
      labelType: NavigationRailLabelType.all,
      destinations: [
        for (final d in data.destinations)
          NavigationRailDestination(
            icon: _badged(d, d.icon),
            selectedIcon: _badged(d, d.selectedIcon ?? d.icon),
            label: Text(d.label),
          ),
      ],
    ),
  ),
);

/// The standing `NavigationDrawer` of an expanded window and wider.
Widget buildShellStandardDrawer(ShellNavigationData data) => _group(
  data.label,
  SafeSides(
    end: false,
    child: SizedBox(
      width: 280,
      child: NavigationDrawer(
        elevation: 0,
        selectedIndex: data.selectedIndex,
        onDestinationSelected: data.onSelected,
        children: [
          ..._drawerDestinations(data.destinations),
          const SizedBox(height: 12),
        ],
      ),
    ),
  ),
);

/// The modal `NavigationDrawer` of a compact window, with its close button.
Widget buildShellModalDrawer(
  BuildContext context,
  ShellNavigationData data,
  String closeLabel,
) => NavigationDrawer(
  selectedIndex: data.selectedIndex,
  onDestinationSelected: (i) {
    Navigator.of(context).maybePop();
    data.onSelected(i);
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
    ..._drawerDestinations(data.destinations),
  ],
);
