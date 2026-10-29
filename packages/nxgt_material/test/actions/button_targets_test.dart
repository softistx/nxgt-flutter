import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/actions.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/layout.dart';

import '../layout/adaptive_shell/adaptive_shell_harness.dart';
import '../support/host.dart';

void main() {
  void expectTarget(WidgetTester tester, Finder finder) {
    expect(finder, findsAtLeastNWidgets(1));
    final size = tester.getSize(finder.first);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpApp(themedHost(Center(child: child)));
    await tester.pumpAndSettle();
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
    group('48 dp buttons on $platform', () {
      void check(String name, Future<void> Function(WidgetTester) body) {
        testWidgets(name, (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            await body(tester);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        });
      }

      check('CopyButton', (tester) async {
        await pump(tester, const CopyButton(value: 'x'));
        expectTarget(tester, find.byType(IconButton));
      });

      check('SplitButton main part and arrow', (tester) async {
        await pump(
          tester,
          SplitButton(
            label: 'Go',
            onPressed: () {},
            menuChildren: const [MenuItemButton(child: Text('Other'))],
          ),
        );
        expectTarget(tester, find.byType(FilledButton));
        expectTarget(tester, find.byType(IconButton));
      });

      check('InlineAlert close button', (tester) async {
        await pump(tester, InlineAlert(message: 'm', onDismiss: () {}));
        expectTarget(tester, find.byType(IconButton));
      });

      check('PasswordField toggle', (tester) async {
        await pump(tester, const PasswordField(label: 'Password'));
        expectTarget(tester, find.byType(IconButton));
      });

      check('AdaptiveShell menu and drawer close buttons', (tester) async {
        await pumpShell(
          tester,
          400,
          buildShell(compact: CompactNavigation.drawer),
        );
        expectTarget(tester, find.byTooltip('Open navigation'));
        await tester.tap(find.byTooltip('Open navigation'));
        await tester.pumpAndSettle();
        expectTarget(tester, find.byTooltip('Close navigation'));
      });
    });
  }
}
