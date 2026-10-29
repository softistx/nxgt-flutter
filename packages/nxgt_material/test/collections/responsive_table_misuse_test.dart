import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/collections.dart';

import '../support/responsive_table_host.dart';

void main() {
  group('misuse', () {
    // The release fallbacks (no columns draws nothing, an out-of-range sort
    // index shows the table unsorted) sit behind the asserts, which stop a
    // debug run before build: tests cannot reach them.
    test('asserts on no columns', () {
      expect(
        () => ResponsiveTable<int>(columns: const [], rows: const []),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'ResponsiveTable.columns must not be empty.',
          ),
        ),
      );
    });

    test('asserts on a sort column out of range', () {
      expect(
        () => ResponsiveTable<(String, String)>(
          columns: tableColumns,
          rows: tablePeople,
          sortColumnIndex: 2,
        ),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'ResponsiveTable.sortColumnIndex is out of range.',
          ),
        ),
      );
    });
  });
}
