import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/collections.dart';

Widget _row(BuildContext context, String item, int index) =>
    ListTile(title: Text(item));

Future<void> main() async {
  await goldenTest(
    'PagedList looks right in light and dark',
    fileName: 'paged_list',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          for (final (name, list) in <(String, PagedList<String>)>[
            (
              'load more button',
              PagedList<String>(
                items: const ['Amoxicillin', 'Ibuprofen', 'Paracetamol'],
                itemBuilder: _row,
                hasMore: true,
                onLoadMore: () async {},
              ),
            ),
            (
              'loading more',
              const PagedList<String>(
                items: ['Amoxicillin', 'Ibuprofen', 'Paracetamol'],
                itemBuilder: _row,
                loading: true,
              ),
            ),
            (
              'inline error',
              PagedList<String>(
                items: const ['Amoxicillin', 'Ibuprofen', 'Paracetamol'],
                itemBuilder: _row,
                error: 'x',
                onRetry: () async {},
              ),
            ),
          ])
            GoldenTestScenario(
              name: '${brightness.name} $name',
              child: SizedBox(
                width: 320,
                height: 420,
                child: Theme(
                  data: ThemeData(
                    colorSchemeSeed: Colors.indigo,
                    brightness: brightness,
                  ),
                  child: Material(child: list),
                ),
              ),
            ),
      ],
    ),
  );
}
