@TestOn('browser')
@Tags(['web'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/theme.dart';

import '../support/host.dart';

/// On the web ints are doubles: the tone picked from a name must be the same
/// as on the VM.
void main() {
  testWidgets('UserAvatar picks the same tones on the web', (tester) async {
    for (final (name, tone) in const [
      ('Ada Lovelace', 'tertiary'),
      ('eve  adams', 'secondary'),
      ('Chloé Durand', 'success'),
    ]) {
      await tester.pumpApp(themedHost(UserAvatar(name: name)));
      final tones = tester.element(find.byType(UserAvatar)).tones;
      final fill = tester
          .widget<CircleAvatar>(find.byType(CircleAvatar))
          .backgroundColor;
      expect(fill, tones[tone]!.container, reason: name);
    }
  });
}
