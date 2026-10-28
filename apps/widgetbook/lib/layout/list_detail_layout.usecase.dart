import 'package:flutter/material.dart';
import 'package:nxgt_material/layout.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ListDetailLayout, path: '[Layout]')
/// The default use-case of [ListDetailLayout].
Widget buildListDetailLayoutDefault(BuildContext context) {
  return const _ListDetailDemo();
}

class _ListDetailDemo extends StatefulWidget {
  const new();

  @override
  State<_ListDetailDemo> createState() => _ListDetailDemoState();
}

class _ListDetailDemoState extends State<_ListDetailDemo> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return ListDetailLayout(
      showDetail: _selected != null,
      onBack: () => setState(() => _selected = null),
      list: ListView(
        children: [
          for (var i = 1; i <= 8; i++)
            ListTile(
              title: Text('Invoice $i'),
              selected: _selected == i,
              onTap: () => setState(() => _selected = i),
            ),
        ],
      ),
      detail: Center(
        child: Text(
          _selected == null ? 'Pick an invoice' : 'Invoice $_selected',
        ),
      ),
    );
  }
}
