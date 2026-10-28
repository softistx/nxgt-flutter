import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/layout.dart';

Widget _window(double width, Widget child) => MediaQuery(
  data: MediaQueryData(size: Size(width, 200)),
  child: SizedBox(
    width: width,
    height: 200,
    child: ColoredBox(color: Colors.black12, child: child),
  ),
);

Future<void> main() async {
  const content = ColoredBox(
    color: Colors.indigo,
    child: SizedBox(height: 120, width: double.infinity),
  );
  await goldenTest(
    'PageBody keeps its gutters and its maximum width',
    fileName: 'page_body',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'compact',
          child: _window(400, const PageBody(child: content)),
        ),
        GoldenTestScenario(
          name: 'expanded',
          child: _window(1000, const PageBody(maxWidth: 800, child: content)),
        ),
      ],
    ),
  );
}
