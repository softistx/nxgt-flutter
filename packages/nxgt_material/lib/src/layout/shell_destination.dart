import 'package:flutter/widgets.dart';

/// One place of an `AdaptiveShell`: an [icon], a [label] and, when it is the
/// current one, a [selectedIcon].
class ShellDestination {
  /// Creates a ShellDestination.
  const new({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  /// The icon, shown when the destination is not selected (and when it is,
  /// without a [selectedIcon]).
  final Widget icon;

  /// The text of the destination, spoken by screen readers and shown by the
  /// rail and the drawer.
  final String label;

  /// The icon of the selected destination, usually the filled variant.
  final Widget? selectedIcon;

  /// A badge over the icon, such as a `Badge` count.
  final Widget? badge;
}

/// What an `AdaptiveShell` uses on a compact window.
enum CompactNavigation {
  /// A bottom navigation bar.
  bar,

  /// A modal navigation drawer opened from an app bar button.
  drawer,
}
