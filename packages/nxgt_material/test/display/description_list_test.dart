import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/actions.dart';
import 'package:nxgt_material/display.dart';

import '../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget child, {double width = 400}) {
  tester.view
    ..physicalSize = Size(width, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpApp(themedHost(child));
}

const _items = [
  DescriptionItem(label: 'Invoice', value: 'INV-2026-0042', copyable: true),
  DescriptionItem(label: 'Customer', value: 'Ada Lovelace'),
];

void main() {
  testWidgets('DescriptionList shows each label and value', (tester) async {
    await _pump(tester, const DescriptionList(items: _items));

    expect(find.text('Invoice'), findsOneWidget);
    expect(find.text('INV-2026-0042'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsOneWidget);
  });

  group('layout', () {
    testWidgets('stacks the value under the label at 599 dp', (tester) async {
      await _pump(tester, const DescriptionList(items: _items), width: 599);

      final label = tester.getTopLeft(find.text('Customer'));
      final value = tester.getTopLeft(find.text('Ada Lovelace'));
      expect(value.dy, greaterThan(label.dy));
      expect(value.dx, label.dx);
    });

    testWidgets('puts the value beside the label at 600 dp', (tester) async {
      await _pump(tester, const DescriptionList(items: _items), width: 600);

      final label = tester.getTopLeft(find.text('Customer'));
      final value = tester.getTopLeft(find.text('Ada Lovelace'));
      expect((value.dy - label.dy).abs(), lessThan(8)); // baseline-aligned
      expect(value.dx, greaterThan(label.dx));
    });

    testWidgets('keeps long text readable at twice the text size', (
      tester,
    ) async {
      await _pump(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            size: Size(600, 800),
            textScaler: TextScaler.linear(2),
          ),
          child: DescriptionList(
            items: [
              DescriptionItem(
                label: 'L' * 60,
                value: 'V' * 120,
                copyable: true,
              ),
            ],
          ),
        ),
        width: 600,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('draws nothing for an empty list', (tester) async {
      await _pump(tester, const DescriptionList(items: []));

      expect(tester.getSize(find.byType(DescriptionList)).height, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('semantics', () {
    testWidgets('reads each row as "label, value" in order', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const DescriptionList(items: _items));

      expect(find.bySemanticsLabel('Invoice, INV-2026-0042'), findsOneWidget);
      expect(find.bySemanticsLabel('Customer, Ada Lovelace'), findsOneWidget);
      final invoice = tester.getTopLeft(
        find.bySemanticsLabel('Invoice, INV-2026-0042'),
      );
      final customer = tester.getTopLeft(
        find.bySemanticsLabel('Customer, Ada Lovelace'),
      );
      expect(invoice.dy, lessThan(customer.dy));
      handle.dispose();
    });

    testWidgets('does not mark labels as headers', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const DescriptionList(items: _items));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Invoice, INV-2026-0042')),
        isNot(matchesSemantics(isHeader: true)),
      );
      handle.dispose();
    });
  });

  group('copyable', () {
    testWidgets('shows a labelled CopyButton only on copyable rows', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const DescriptionList(items: _items));

      expect(find.byType(CopyButton), findsOneWidget);
      expect(find.bySemanticsLabel('Copy Invoice'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('names the item in French', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        themedHost(
          const DescriptionList(items: _items),
          locale: const Locale('fr'),
        ),
      );

      expect(find.bySemanticsLabel('Copier « Invoice »'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('copies the value', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await _pump(tester, const DescriptionList(items: _items));

      await tester.tap(find.byType(CopyButton));
      await tester.pump();

      expect(copied, 'INV-2026-0042');
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('RTL', () {
    testWidgets('starts the label at the right edge', (tester) async {
      await _pump(
        tester,
        const Directionality(
          textDirection: TextDirection.rtl,
          child: DescriptionList(items: _items),
        ),
        width: 600,
      );

      final label = tester.getTopRight(find.text('Customer'));
      final value = tester.getTopRight(find.text('Ada Lovelace'));
      expect(value.dx, lessThan(label.dx));
      expect(label.dx, greaterThan(300));
    });
  });
}
