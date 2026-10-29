import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/overlays.dart';
import 'package:nxgt_material/theme.dart';

Future<void> main() async {
  await goldenTest(
    'FormDialog looks right, compact and medium, light and dark',
    fileName: 'form_dialog',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final brightness in Brightness.values)
          for (final fullscreen in const [true, false])
            GoldenTestScenario(
              name: '${brightness.name} ${fullscreen ? 'compact' : 'medium'}',
              constraints: BoxConstraints.tight(
                fullscreen ? const Size(360, 560) : const Size(640, 560),
              ),
              child: Theme(
                data: brightness == Brightness.light
                    ? ThemePresets.ocean.light()
                    : ThemePresets.ocean.dark(),
                child: FormDialog<void>(
                  title: 'New invoice',
                  submitLabel: 'Create',
                  fullscreen: fullscreen,
                  onSubmit: () async {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: 'ACME Corp',
                        decoration: const InputDecoration(
                          labelText: 'Customer',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}
