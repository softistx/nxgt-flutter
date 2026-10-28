import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_widgetbook/main.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  testWidgets('the catalogue builds', (tester) async {
    await tester.pumpWidget(const WidgetbookApp());
    expect(find.byType(Widgetbook), findsOneWidget);
  });
}
