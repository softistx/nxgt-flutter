@TestOn('browser')
@Tags(['web'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/selection.dart';

import '../support/host.dart';

void main() {
  testWidgets('SwitchField error: alert role, no live region', (tester) async {
    final handle = tester.ensureSemantics();
    final key = GlobalKey<FormState>();
    await tester.pumpApp(
      formHost([
        SwitchField(label: 'Notifications', validator: (_) => 'Turn this on'),
      ], formKey: key),
    );
    key.currentState!.validate();
    await tester.pump();

    final alert = find.ancestor(
      of: find.text('Turn this on'),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.role == SemanticsRole.alert,
      ),
    );
    expect(alert, findsOneWidget);
    expect(
      tester
          .getSemantics(find.text('Turn this on'))
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isFalse,
    );
    handle.dispose();
  });
}
