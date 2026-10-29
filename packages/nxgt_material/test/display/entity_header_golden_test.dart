import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'EntityHeader looks right compact and medium, light and dark',
    fileName: 'entity_header',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final brightness in Brightness.values)
          for (final (name, width) in const [
            ('compact', 360.0),
            ('medium', 640.0),
          ])
            GoldenTestScenario(
              name: '${brightness.name} $name',
              constraints: BoxConstraints(maxWidth: width),
              child: Theme(
                data: brightness == Brightness.light
                    ? ThemePresets.ocean.light()
                    : ThemePresets.ocean.dark(),
                child: Material(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: MediaQuery(
                      data: MediaQueryData(size: Size(width, 400)),
                      child: EntityHeader(
                        title: 'Ada Lovelace',
                        subtitle: 'ada@example.com',
                        leading: const UserAvatar(
                          name: 'Ada Lovelace',
                          size: 56,
                        ),
                        status: const StatusIndicator(
                          label: 'Active',
                          tone: FeedbackTone.success,
                        ),
                        actions: [
                          EntityAction(
                            label: 'Edit',
                            icon: Icons.edit,
                            onPressed: () {},
                          ),
                          EntityAction(
                            label: 'Delete',
                            icon: Icons.delete_outline,
                            destructive: true,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}
