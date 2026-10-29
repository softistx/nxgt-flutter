@TestOn('browser')
@Tags(['web'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/collections.dart';

import '../support/host.dart';

void main() {
  testWidgets(
    'PagedList: "N more loaded" has the status role, no live region',
    (tester) async {
      final handle = tester.ensureSemantics();
      var items = ['a', 'b', 'c'];
      late StateSetter update;
      await tester.pumpApp(
        themedHost(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return PagedList<String>(
                items: items,
                itemBuilder: (context, item, index) => Text(item),
                hasMore: true,
                onLoadMore: () async => update(() => items = [...items, 'd']),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Show more'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      final node = tester.getSemantics(find.bySemanticsLabel('1 more loaded'));
      final data = node.getSemanticsData();
      expect(data.flagsCollection.isLiveRegion, isFalse);
      var hasRole = false;
      void visit(SemanticsNode n) {
        if (n.getSemanticsData().role == SemanticsRole.status &&
            !n.getSemanticsData().flagsCollection.isLiveRegion) {
          hasRole = true;
        }
        n.visitChildren((c) {
          visit(c);
          return true;
        });
      }

      visit(
        tester
            .binding
            .renderViews
            .first
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!,
      );
      expect(hasRole, isTrue);
      await tester.pump(const Duration(seconds: 3));
      handle.dispose();
    },
  );
}
