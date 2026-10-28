import 'package:nxgt_material/src/layout/shell_destination.dart';

/// Asserts the arguments of an `AdaptiveShell`: at least two destinations and
/// a selected index within them.
///
/// Only debug builds check. A release build degrades instead: the body is
/// shown without navigation below two destinations, and the index is clamped.
void assertShellArguments(List<ShellDestination> destinations, int selected) {
  assert(
    destinations.length >= 2,
    'AdaptiveShell needs at least two destinations.',
  );
  assert(
    selected >= 0 && selected < destinations.length,
    'AdaptiveShell.selectedIndex is out of range.',
  );
}
