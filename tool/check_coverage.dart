// Fails when a package's line coverage (coverage/lcov.info) is below a
// threshold. A package with a test/ folder but no lcov file fails (the tests
// did not write coverage). A package without test/ or without instrumented
// lines is skipped: nothing to cover yet.
//
// Usage: dart run tool/check_coverage.dart <percent> <package dir>...
import 'dart:io';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('usage: check_coverage.dart <percent> <package dir>...');
    exit(64);
  }
  final threshold = double.parse(args.first);
  var failed = false;
  for (final dir in args.skip(1)) {
    final file = File('$dir/coverage/lcov.info');
    if (!file.existsSync()) {
      if (Directory('$dir/test').existsSync()) {
        stderr.writeln(
          '$dir: has a test/ folder but no coverage/lcov.info '
          '(run the tests with coverage first)',
        );
        failed = true;
      } else {
        stdout.writeln('$dir: no test/ folder, skipped');
      }
      continue;
    }
    var found = 0;
    var hit = 0;
    for (final line in file.readAsLinesSync()) {
      if (line.startsWith('LF:')) found += int.parse(line.substring(3));
      if (line.startsWith('LH:')) hit += int.parse(line.substring(3));
    }
    if (found == 0) {
      stdout.writeln('$dir: no instrumented lines, skipped');
      continue;
    }
    final percent = hit * 100 / found;
    final ok = percent >= threshold;
    stdout.writeln(
      '$dir: ${percent.toStringAsFixed(1)} % '
      '(${ok ? 'ok' : 'below $threshold %'})',
    );
    if (!ok) failed = true;
  }
  if (failed) exit(1);
}
