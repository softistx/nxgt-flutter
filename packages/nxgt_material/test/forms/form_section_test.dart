import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/forms.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );

  testWidgets('shows the title, the description and the children in order', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const FormSection(
          title: 'Account',
          description: 'How you sign in.',
          children: [Text('one'), Text('two')],
        ),
      ),
    );

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('How you sign in.'), findsOneWidget);
    final ys = [
      for (final t in ['Account', 'How you sign in.', 'one', 'two'])
        tester.getTopLeft(find.text(t)).dy,
    ];
    expect(ys, [...ys]..sort());
  });

  testWidgets('omits the description when there is none', (tester) async {
    await tester.pumpWidget(
      host(const FormSection(title: 'Account', children: [Text('one')])),
    );

    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('spacing separates the children', (tester) async {
    await tester.pumpWidget(
      host(
        const FormSection(
          title: 'Account',
          spacing: 40,
          children: [
            SizedBox(height: 10, key: Key('a')),
            SizedBox(height: 10, key: Key('b')),
          ],
        ),
      ),
    );

    final gap =
        tester.getTopLeft(find.byKey(const Key('b'))).dy -
        tester.getBottomLeft(find.byKey(const Key('a'))).dy;
    expect(gap, 40);
  });

  group('semantics', () {
    testWidgets('the title is a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const FormSection(title: 'Account', children: [Text('one')])),
      );

      expect(
        tester.getSemantics(find.text('Account')),
        matchesSemantics(label: 'Account', isHeader: true),
      );
      handle.dispose();
    });
  });
}
