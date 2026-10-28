import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/layout.dart';
import 'package:nxgt_material/theme.dart';

const _places = [
  ShellDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  ShellDestination(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
  ShellDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
];

Widget _shell(
  double width,
  double height, {
  Brightness brightness = Brightness.light,
  CompactNavigation compact = CompactNavigation.bar,
}) => Theme(
  data: brightness == Brightness.light
      ? ThemePresets.ocean.light()
      : ThemePresets.ocean.dark(),
  child: MediaQuery(
    data: MediaQueryData(size: Size(width, height)),
    child: SizedBox(
      width: width,
      height: height,
      child: AdaptiveShell(
        destinations: _places,
        selectedIndex: 1,
        onSelected: (_) {},
        compactNavigation: compact,
        title: const Text('Acme'),
        body: const Center(child: Text('Body')),
      ),
    ),
  ),
);

Future<void> main() async {
  await goldenTest(
    'AdaptiveShell is a bar, a rail and a drawer',
    fileName: 'adaptive_shell',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(name: 'compact', child: _shell(400, 360)),
        GoldenTestScenario(
          name: 'compact dark',
          child: _shell(400, 360, brightness: Brightness.dark),
        ),
        GoldenTestScenario(name: 'medium', child: _shell(700, 360)),
        GoldenTestScenario(name: 'expanded', child: _shell(1000, 360)),
      ],
    ),
  );
}
