import 'dart:async';

/// Alchemist does not compile for the web, and goldens are not run there:
/// the web tests run as they are.
Future<void> runWithGoldenConfig(FutureOr<void> Function() testMain) async {
  await testMain();
}
