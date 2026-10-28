import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/src/{{category.snakeCase()}}/{{name.snakeCase()}}.dart';

void main() {
  Widget host() => const MaterialApp(
    home: Scaffold(body: {{name.pascalCase()}}(label: 'Hello')),
  );

  testWidgets('{{name.pascalCase()}} shows its label', (tester) async {
    await tester.pumpWidget(host());

    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('{{name.pascalCase()}} exposes its label to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host());

    expect(find.bySemanticsLabel('Hello'), findsOneWidget);
    handle.dispose();
  });
}
