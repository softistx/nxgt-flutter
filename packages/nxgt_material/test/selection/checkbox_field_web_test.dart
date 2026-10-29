@TestOn('browser')
@Tags(['web'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/selection.dart';

import '../support/host.dart';

void main() {
  testWidgets('CheckboxField error: alert role, no live region', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final key = GlobalKey<FormState>();
    await tester.pumpApp(
      formHost([
        const CheckboxField(label: 'Accept', required: true),
      ], formKey: key),
    );
    key.currentState!.validate();
    await tester.pump();

    final data = tester
        .getSemantics(find.text('This field is required'))
        .getSemanticsData();
    expect(data.role, SemanticsRole.alert);
    expect(data.flagsCollection.isLiveRegion, isFalse);
    handle.dispose();
  });
}
