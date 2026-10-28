import 'package:flutter/foundation.dart';
import 'package:nxgt_material/src/layout/shell_destination.dart';

/// Reports, through [FlutterError.reportError], what is wrong with the
/// destinations or the selected index of an `AdaptiveShell`.
void reportShellProblems(List<ShellDestination> destinations, int selected) {
  final count = destinations.length;
  if (count < 2) {
    _report([
      ErrorSummary('AdaptiveShell needs at least two destinations.'),
      ErrorDescription('It was given $count.'),
      ErrorHint(
        'Navigation bars and rails need two or more places; the body is '
        'shown without navigation until there are.',
      ),
    ]);
  } else if (selected < 0 || selected >= count) {
    _report([
      ErrorSummary('AdaptiveShell.selectedIndex is out of range.'),
      ErrorDescription('It was $selected for $count destinations.'),
      ErrorHint(
        'Use an index from 0 to ${count - 1}; the nearest one is selected '
        'meanwhile.',
      ),
    ]);
  }
}

void _report(List<DiagnosticsNode> parts) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: FlutterError.fromParts(parts),
      library: 'nxgt_material',
      context: ErrorDescription('while building an AdaptiveShell'),
    ),
  );
}
