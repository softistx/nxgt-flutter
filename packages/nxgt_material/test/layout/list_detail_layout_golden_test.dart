import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/layout.dart';
import 'package:nxgt_material/theme.dart';

Widget _layout(double width, {required bool showDetail}) => Theme(
  data: ThemePresets.ocean.light(),
  child: Material(
    child: SizedBox(
      width: width,
      height: 240,
      child: ListDetailLayout(
        showDetail: showDetail,
        list: ListView(
          children: const [
            ListTile(title: Text('Invoice 1')),
            ListTile(title: Text('Invoice 2'), selected: true),
          ],
        ),
        detail: const Center(child: Text('Invoice 2')),
      ),
    ),
  ),
);

Future<void> main() async {
  await goldenTest(
    'ListDetailLayout shows two panes, then one',
    fileName: 'list_detail_layout',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'compact list',
          child: _layout(400, showDetail: false),
        ),
        GoldenTestScenario(
          name: 'compact detail',
          child: _layout(400, showDetail: true),
        ),
        GoldenTestScenario(
          name: 'expanded',
          child: _layout(1000, showDetail: true),
        ),
      ],
    ),
  );
}
