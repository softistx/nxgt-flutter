import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/actions.dart';
import 'package:nxgt_material/forms.dart';

Future<void> main() async {
  await goldenTest(
    'SubmitButton looks right in light and dark',
    fileName: 'submit_button',
    builder: () => GoldenTestGroup(
      children: [
        for (final brightness in Brightness.values)
          GoldenTestScenario(
            name: brightness.name,
            child: Theme(
              data: ThemeData(
                colorSchemeSeed: Colors.indigo,
                brightness: brightness,
              ),
              child: SizedBox(
                width: 320,
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      SubmitButton(label: 'Send', onSubmit: () async {}),
                      SubmitButton(
                        label: 'Send',
                        icon: const Icon(Icons.send),
                        variant: AsyncButtonVariant.tonal,
                        onSubmit: () async {},
                      ),
                      const SubmitButton(label: 'Disabled', onSubmit: null),
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
