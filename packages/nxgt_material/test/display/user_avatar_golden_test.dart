import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'UserAvatar looks right with initials and presence, light and dark',
    fileName: 'user_avatar',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final brightness in Brightness.values)
          GoldenTestScenario(
            name: brightness.name,
            child: Theme(
              data: brightness == Brightness.light
                  ? ThemePresets.ocean.light()
                  : ThemePresets.ocean.dark(),
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          for (final name in const [
                            'Ada Lovelace',
                            'Bob Martin',
                            'Chloé Durand',
                            'Dan',
                            'Eve Adams',
                            'Farid',
                          ])
                            UserAvatar(name: name),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          for (final presence in AvatarPresence.values)
                            UserAvatar(
                              name: 'Ada Lovelace',
                              size: 56,
                              presence: presence,
                            ),
                          const UserAvatar(name: ''),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
