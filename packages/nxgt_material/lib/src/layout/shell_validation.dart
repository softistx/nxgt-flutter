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

/// The index a shell selects: [selected] clamped to the [count] destinations
/// (0 when there are none), so a release build still builds.
int shellIndex(int selected, int count) =>
    selected.clamp(0, count == 0 ? 0 : count - 1);

/// Whether a shell with [count] destinations shows navigation; below two it
/// shows the body alone.
bool shellHasNavigation(int count) => count >= 2;
