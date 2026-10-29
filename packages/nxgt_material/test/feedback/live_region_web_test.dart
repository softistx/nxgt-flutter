@TestOn('browser')
@Tags(['web'])
library;

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/src/feedback/live_region.dart';

import '../support/host.dart';

/// Every node of the semantics tree, root first.
List<SemanticsNode> _nodes(WidgetTester tester) {
  final nodes = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    nodes.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return nodes;
}

/// Checks the web branch: [role] is set, no node is a live region, and
/// [text] is still reachable in the semantics tree.
void _expectRoleWithoutLiveRegion(
  WidgetTester tester, {
  required SemanticsRole role,
  required String text,
}) {
  final nodes = _nodes(tester);
  final withRole = nodes.where((n) => n.getSemanticsData().role == role);
  expect(withRole, isNotEmpty, reason: 'a node with role $role');
  for (final node in nodes) {
    expect(
      node.getSemanticsData().flagsCollection.isLiveRegion,
      isFalse,
      reason: 'node ${node.id} must not be a live region on the web',
    );
  }
  expect(
    tester.getSemantics(find.text(text)).label,
    contains(text),
    reason: 'the announced text stays in semantics',
  );
}

void main() {
  test('liveRegionUnderRole is off on the web', () {
    expect(liveRegionUnderRole, isFalse);
  });

  testWidgets('LoadingState: status role, no live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(const LoadingState()));

    _expectRoleWithoutLiveRegion(
      tester,
      role: SemanticsRole.status,
      text: 'Loading',
    );
    handle.dispose();
  });

  testWidgets('EmptyState: status role, no live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(const EmptyState()));

    _expectRoleWithoutLiveRegion(
      tester,
      role: SemanticsRole.status,
      text: 'Nothing here yet',
    );
    handle.dispose();
  });

  testWidgets('ErrorState: alert role, no live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(const ErrorState()));

    _expectRoleWithoutLiveRegion(
      tester,
      role: SemanticsRole.alert,
      text: 'Something went wrong',
    );
    handle.dispose();
  });

  testWidgets('InlineAlert: role of its tone, no live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      themedHost(
        const InlineAlert(
          tone: FeedbackTone.error,
          title: 'Payment failed',
          message: 'Try another card.',
        ),
      ),
    );

    _expectRoleWithoutLiveRegion(
      tester,
      role: SemanticsRole.alert,
      text: 'Payment failed',
    );
    handle.dispose();
  });
}
