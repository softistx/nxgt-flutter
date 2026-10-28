import 'package:flutter/foundation.dart';
import 'package:nxgt_material/src/theme/oklch.dart';

/// The OKLCH colour a tone is generated from, light and dark.
///
/// When [dark] is left out, the dark tone starts from [light] lifted to a
/// readable lightness.
@immutable
class ToneSeed {
  /// Creates a seed from its [light] colour and an optional [dark] one.
  const new(this.light, {this.dark});

  /// The seed in light mode.
  final Oklch light;

  /// The seed in dark mode, or `null` to derive it from [light].
  final Oklch? dark;

  @override
  bool operator ==(Object other) =>
      other is ToneSeed && other.light == light && other.dark == dark;

  @override
  int get hashCode => Object.hash(light, dark);
}

/// The seeds of the status tones, from `@nxgt/material`'s `STATUS` table.
abstract final class StatusSeeds {
  /// Success, a green teal.
  static const success = ToneSeed(
    Oklch(0.46, 0.118, 184.704),
    dark: Oklch(0.6, 0.118, 184.704),
  );

  /// Info, a blue.
  static const info = ToneSeed(
    Oklch(0.48, 0.165, 254.624),
    dark: Oklch(0.707, 0.165, 254.624),
  );

  /// Warning, an amber.
  static const warning = ToneSeed(
    Oklch(0.52, 0.13, 62),
    dark: Oklch(0.7, 0.15, 70),
  );
}
