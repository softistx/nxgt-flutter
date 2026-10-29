import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/collections.dart';

import '../support/responsive_table_host.dart';

void main() {
  group('width', () {
    testWidgets('does not scroll when it fits a padded page', (tester) async {
      await pumpTable(
        tester,
        tableHost(
          Padding(
            padding: const EdgeInsets.all(16),
            child: ResponsiveTable<(String, String, String)>(
              columns: [
                for (final label in ['A', 'B', 'C'])
                  TableColumn(label: label, value: (r) => r.$1),
              ],
              rows: const [('x', 'y', 'z')],
            ),
          ),
        ),
      );

      final scroll = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(ResponsiveTable<(String, String, String)>),
          matching: find.byType(Scrollable),
        ),
      );
      expect(scroll.position.maxScrollExtent, 0);
    });

    testWidgets('scrolls sideways with many wide columns', (tester) async {
      await pumpTable(
        tester,
        tableHost(
          ResponsiveTable<(String, String)>(
            columns: [
              for (var i = 0; i < 12; i++)
                TableColumn(
                  label: 'A rather long column header $i',
                  value: (r) => r.$1,
                ),
            ],
            rows: tablePeople,
          ),
        ),
      );

      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(ResponsiveTable<(String, String)>),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(scroll.position.maxScrollExtent, greaterThan(0));
    });
  });
}
