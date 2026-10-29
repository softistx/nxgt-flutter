import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/layout.dart';

import '../../support/host.dart';

const shellPlaces = [
  ShellDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  ShellDestination(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
  ShellDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
];

Widget buildShell({
  int selected = 0,
  ValueChanged<int>? onSelected,
  CompactNavigation compact = CompactNavigation.bar,
  Widget? title,
  List<ShellDestination> destinations = shellPlaces,
}) => AdaptiveShell(
  destinations: destinations,
  selectedIndex: selected,
  onSelected: onSelected ?? (_) {},
  compactNavigation: compact,
  title: title,
  body: const Align(
    alignment: Alignment.topLeft,
    child: Text('Body', key: Key('body')),
  ),
);

Future<void> pumpShell(
  WidgetTester tester,
  double width,
  Widget shell, {
  double height = 800,
  Locale locale = const Locale('en'),
  EdgeInsets? insets,
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpApp(
    themedHost(
      insets == null
          ? shell
          : Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(padding: insets, viewPadding: insets),
                child: shell,
              ),
            ),
      locale: locale,
    ),
  );
}

/// How many shapes the ink of a [Material] has drawn: a hover or focus

/// highlight adds one. `Material.of` is the ink controller, a render object.
int inkDraws(RenderObject ink) {
  var total = 0;
  for (final draw in [#drawRect, #drawRRect, #drawPath, #drawCircle]) {
    for (var n = 0; n < 8; n++) {
      try {
        expect(ink, paintsExactlyCountTimes(draw, n));
        total += n;
        break;
      } on TestFailure {
        continue;
      }
    }
  }
  return total;
}
