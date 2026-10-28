import 'package:flutter/material.dart';
import 'package:nxgt_material/layout.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _places = [
  ShellDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  ShellDestination(
    icon: Icon(Icons.inbox_outlined),
    selectedIcon: Icon(Icons.inbox),
    label: 'Inbox',
    badge: Badge(label: Text('3')),
  ),
  ShellDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    label: 'Settings',
  ),
];

@widgetbook.UseCase(name: 'Default', type: AdaptiveShell, path: '[Layout]')
/// The default use-case of [AdaptiveShell]; resize the viewport to see the
/// bar, the rail and the drawer.
Widget buildAdaptiveShellDefault(BuildContext context) {
  return _ShellDemo(
    compact: context.knobs.object.dropdown(
      label: 'Compact navigation',
      options: CompactNavigation.values,
      initialOption: CompactNavigation.bar,
      labelBuilder: (value) => value.name,
    ),
    title: context.knobs.boolean(label: 'Title', initialValue: true)
        ? const Text('Acme')
        : null,
  );
}

class _ShellDemo extends StatefulWidget {
  const new({required this.compact, required this.title});

  final CompactNavigation compact;
  final Widget? title;

  @override
  State<_ShellDemo> createState() => _ShellDemoState();
}

class _ShellDemoState extends State<_ShellDemo> {
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      destinations: _places,
      selectedIndex: _selected,
      onSelected: (i) => setState(() => _selected = i),
      compactNavigation: widget.compact,
      title: widget.title,
      body: Center(
        child: Text('${_places[_selected].label} (${context.windowSize.name})'),
      ),
    );
  }
}
