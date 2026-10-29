import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Only the CI goldens (Ahem font, no platform fonts) are generated and
/// compared, so a golden is byte-identical on every machine.
Future<void> runWithGoldenConfig(FutureOr<void> Function() testMain) {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
    ),
    run: () async {
      await testMain();
    },
  );
}
