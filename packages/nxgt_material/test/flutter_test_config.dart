import 'dart:async';

import 'support/golden_config.dart'
    if (dart.library.js_interop) 'support/golden_config_web.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) =>
    runWithGoldenConfig(testMain);
