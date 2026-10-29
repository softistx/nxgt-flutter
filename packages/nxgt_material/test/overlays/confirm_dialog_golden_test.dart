import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/overlays.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'ConfirmDialog looks right, plain and destructive, light and dark',
    fileName: 'confirm_dialog',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final brightness in Brightness.values)
          for (final destructive in const [false, true])
            GoldenTestScenario(
              name:
                  '${brightness.name} ${destructive ? 'destructive' : 'plain'}',
              constraints: const BoxConstraints(maxWidth: 360),
              child: Theme(
                data: brightness == Brightness.light
                    ? ThemePresets.ocean.light()
                    : ThemePresets.ocean.dark(),
                child: ConfirmDialog(
                  title: 'Delete invoice?',
                  message:
                      'The invoice and its payments are removed. This '
                      'cannot be undone.',
                  confirmLabel: destructive ? 'Delete' : null,
                  destructive: destructive,
                ),
              ),
            ),
      ],
    ),
  );
}
