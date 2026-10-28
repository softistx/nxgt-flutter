import 'package:flutter/material.dart';
import 'package:nxgt_material/src/theme/tone_colors.dart';
import 'package:nxgt_material/src/theme/tone_seed.dart';

/// The names a tone cannot take: the library's own and the ones the
/// components of `@nxgt/material` set themselves.
const reservedToneNames = {
  'primary',
  'secondary',
  'tertiary',
  'success',
  'info',
  'warning',
  'error',
  'neutral',
  'strong',
  'subtle',
  'mixed',
  'custom',
  'default',
  'critical',
  'expired',
};

/// The tones of a theme: the eight of `@nxgt/material` plus the ones an app
/// adds, each with a colour, an on-colour, a container and an on-container.
///
/// Read it with `context.tones`.
@immutable
class Tones extends ThemeExtension<Tones> {
  /// Creates the tones from the eight named ones and the app's own.
  const new({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.success,
    required this.info,
    required this.warning,
    required this.error,
    required this.neutral,
    this.custom = const {},
  });

  /// Builds the tones for a [scheme]: primary, error and neutral are read from
  /// it, the others are generated from their seeds.
  ///
  /// [secondary] and [tertiary] default to the scheme's. [tones] adds app
  /// tones, and may replace `success`, `info` and `warning`.
  factory fromScheme(
    ColorScheme scheme, {
    ToneSeed? secondary,
    ToneSeed? tertiary,
    Map<String, ToneSeed> tones = const {},
  }) {
    final brightness = scheme.brightness;
    ToneColors solve(ToneSeed seed) => ToneColors.fromSeed(
      brightness == Brightness.dark
          ? seed.dark ?? seed.light.copyWith(l: 0.72)
          : seed.light,
      brightness,
    );
    ToneColors status(String name, ToneSeed fallback) =>
        solve(tones[name] ?? fallback);
    return Tones(
      primary: ToneColors(
        color: scheme.primary,
        onColor: scheme.onPrimary,
        container: scheme.primaryContainer,
        onContainer: scheme.onPrimaryContainer,
      ),
      secondary: secondary == null
          ? ToneColors(
              color: scheme.secondary,
              onColor: scheme.onSecondary,
              container: scheme.secondaryContainer,
              onContainer: scheme.onSecondaryContainer,
            )
          : solve(secondary),
      tertiary: tertiary == null
          ? ToneColors(
              color: scheme.tertiary,
              onColor: scheme.onTertiary,
              container: scheme.tertiaryContainer,
              onContainer: scheme.onTertiaryContainer,
            )
          : solve(tertiary),
      success: status('success', StatusSeeds.success),
      info: status('info', StatusSeeds.info),
      warning: status('warning', StatusSeeds.warning),
      error: ToneColors(
        color: scheme.error,
        onColor: scheme.onError,
        container: scheme.errorContainer,
        onContainer: scheme.onErrorContainer,
      ),
      neutral: ToneColors(
        color: scheme.onSurfaceVariant,
        onColor: scheme.surface,
        container: scheme.surfaceContainerHighest,
        onContainer: scheme.onSurface,
      ),
      custom: {
        for (final entry in tones.entries)
          if (!reservedToneNames.contains(entry.key))
            entry.key: solve(entry.value),
      },
    );
  }

  /// The brand tone, read from the colour scheme.
  final ToneColors primary;

  /// The supporting tone.
  final ToneColors secondary;

  /// The accent tone.
  final ToneColors tertiary;

  /// Done, saved, paid.
  final ToneColors success;

  /// Neutral information.
  final ToneColors info;

  /// Needs attention, not yet wrong.
  final ToneColors warning;

  /// Failed or destructive.
  final ToneColors error;

  /// No meaning: a muted fill.
  final ToneColors neutral;

  /// The tones the app declared, by name.
  final Map<String, ToneColors> custom;

  /// The tone called [name]: a named one or one the app declared.
  ///
  /// Throws an [ArgumentError] for an unknown name.
  ToneColors operator [](String name) => switch (name) {
    'primary' => primary,
    'secondary' => secondary,
    'tertiary' => tertiary,
    'success' => success,
    'info' => info,
    'warning' => warning,
    'error' => error,
    'neutral' => neutral,
    _ =>
      custom[name] ?? (throw ArgumentError.value(name, 'name', 'Unknown tone')),
  };

  /// Every tone with its name, the eight named ones first.
  Map<String, ToneColors> get all => {
    'primary': primary,
    'secondary': secondary,
    'tertiary': tertiary,
    'success': success,
    'info': info,
    'warning': warning,
    'error': error,
    'neutral': neutral,
    ...custom,
  };

  @override
  Tones copyWith({
    ToneColors? primary,
    ToneColors? secondary,
    ToneColors? tertiary,
    ToneColors? success,
    ToneColors? info,
    ToneColors? warning,
    ToneColors? error,
    ToneColors? neutral,
    Map<String, ToneColors>? custom,
  }) => Tones(
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    tertiary: tertiary ?? this.tertiary,
    success: success ?? this.success,
    info: info ?? this.info,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    neutral: neutral ?? this.neutral,
    custom: custom ?? this.custom,
  );

  @override
  Tones lerp(Tones? other, double t) {
    if (other == null) return this;
    ToneColors mix(ToneColors a, ToneColors b) => a.lerp(b, t);
    return Tones(
      primary: mix(primary, other.primary),
      secondary: mix(secondary, other.secondary),
      tertiary: mix(tertiary, other.tertiary),
      success: mix(success, other.success),
      info: mix(info, other.info),
      warning: mix(warning, other.warning),
      error: mix(error, other.error),
      neutral: mix(neutral, other.neutral),
      custom: {
        for (final name in {...custom.keys, ...other.custom.keys})
          if (custom[name] != null && other.custom[name] != null)
            name: mix(custom[name]!, other.custom[name]!)
          else
            name:
                (t < 0.5 ? custom[name] : other.custom[name]) ??
                (custom[name] ?? other.custom[name])!,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Tones &&
      other.primary == primary &&
      other.secondary == secondary &&
      other.tertiary == tertiary &&
      other.success == success &&
      other.info == info &&
      other.warning == warning &&
      other.error == error &&
      other.neutral == neutral &&
      other.custom.length == custom.length &&
      other.custom.entries.every((e) => custom[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
    primary,
    secondary,
    tertiary,
    success,
    info,
    warning,
    error,
    neutral,
    Object.hashAll(custom.entries.map((e) => Object.hash(e.key, e.value))),
  );
}
