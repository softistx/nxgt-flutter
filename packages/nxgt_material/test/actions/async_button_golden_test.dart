import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/actions.dart';

Future<void> main() async {
  await goldenTest(
    'AsyncButton looks right in light and dark',
    fileName: 'async_button',
    // The spinner never settles; one frame is the golden.
    pumpBeforeTest: pumpOnce,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  for (final variant in AsyncButtonVariant.values)
                    AsyncButton(
                      label: variant.name,
                      variant: variant,
                      onPressed: () async {},
                    ),
                  AsyncButton(
                    label: 'loading',
                    loading: true,
                    onPressed: () async {},
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
