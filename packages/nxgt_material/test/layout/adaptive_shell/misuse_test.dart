import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import 'adaptive_shell_harness.dart';

const _one = ShellDestination(icon: Icon(Icons.home), label: 'Home');

void main() {
  group('misuse asserts', () {
    testWidgets('fewer than two destinations', (tester) async {
      await pumpShell(tester, 400, buildShell(destinations: const [_one]));
      final error = tester.takeException();
      expect(error, isA<AssertionError>());
      expect(
        error.toString(),
        contains('AdaptiveShell needs at least two destinations.'),
      );
    });

    testWidgets('an out-of-range index', (tester) async {
      await pumpShell(tester, 400, buildShell(selected: 7));
      final error = tester.takeException();
      expect(error, isA<AssertionError>());
      expect(
        error.toString(),
        contains('AdaptiveShell.selectedIndex is out of range.'),
      );
    });

    testWidgets('a valid shell asserts nothing', (tester) async {
      await pumpShell(tester, 400, buildShell());
      expect(tester.takeException(), isNull);
    });
  });
}
