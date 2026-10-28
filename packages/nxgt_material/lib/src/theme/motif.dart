import 'package:flutter/material.dart';
import 'package:nxgt_material/src/theme/background_preset.dart';

/// Which tone a background is drawn in.
enum MotifTone {
  /// The primary tone.
  primary,

  /// The secondary tone.
  secondary,

  /// The tertiary tone.
  tertiary,

  /// Greys.
  neutral,

  /// Success.
  success,

  /// Warning.
  warning,

  /// Info.
  info,

  /// Error.
  error,

  /// All the accent tones.
  mixed,
}

/// How strong a background is.
enum MotifIntensity {
  /// Barely there.
  subtle,

  /// The default.
  standard,

  /// Strong.
  vivid,
}

/// How many items a motif draws.
enum MotifDensity {
  /// Few.
  low,

  /// The default.
  standard,

  /// Many.
  high,
}

/// How big a motif's items are.
enum MotifSize {
  /// Small.
  small,

  /// Several sizes.
  mixed,

  /// Large.
  large,
}

/// Whether a motif's shapes are filled.
enum MotifFill {
  /// Solid shapes.
  filled,

  /// Outlines.
  outline,

  /// Both.
  mixed,
}

/// The background and icon motif of a theme: the data of
/// `@nxgt/material`'s `background` key. It describes the decoration; the app
/// draws it behind a hero, an empty state or a sign-in screen.
///
/// Read it with `context.motif`.
@immutable
class ThemeMotif extends ThemeExtension<ThemeMotif> {
  /// Creates a motif.
  const new({
    this.preset = BackgroundPreset.gradient,
    this.tone = MotifTone.primary,
    this.intensity = MotifIntensity.standard,
    this.seed = 0,
    this.shapes = const [],
    this.density = MotifDensity.standard,
    this.size = MotifSize.mixed,
    this.rotate = false,
    this.fill = MotifFill.mixed,
    this.moonPosition,
  });

  /// The no-decoration motif: `background: false` in `@nxgt/material`.
  static const none = ThemeMotif();

  /// The preset to draw.
  final BackgroundPreset preset;

  /// The tone the preset is drawn in.
  final MotifTone tone;

  /// How strong the preset is.
  final MotifIntensity intensity;

  /// The seed of the random layout, so it is the same on every launch.
  final int seed;

  /// The shape ids a motif preset draws, such as `ring` or `m3-flower`; empty
  /// for the preset's own.
  final List<String> shapes;

  /// How many items are drawn.
  final MotifDensity density;

  /// How big the items are.
  final MotifSize size;

  /// Whether items are rotated.
  final bool rotate;

  /// Whether shapes are filled.
  final MotifFill fill;

  /// Where the `moon` preset puts the moon, as fractions of the frame.
  final Offset? moonPosition;

  @override
  ThemeMotif copyWith({
    BackgroundPreset? preset,
    MotifTone? tone,
    MotifIntensity? intensity,
    int? seed,
    List<String>? shapes,
    MotifDensity? density,
    MotifSize? size,
    bool? rotate,
    MotifFill? fill,
    Offset? moonPosition,
  }) => ThemeMotif(
    preset: preset ?? this.preset,
    tone: tone ?? this.tone,
    intensity: intensity ?? this.intensity,
    seed: seed ?? this.seed,
    shapes: shapes ?? this.shapes,
    density: density ?? this.density,
    size: size ?? this.size,
    rotate: rotate ?? this.rotate,
    fill: fill ?? this.fill,
    moonPosition: moonPosition ?? this.moonPosition,
  );

  /// A motif does not blend: the switch happens halfway.
  @override
  ThemeMotif lerp(ThemeMotif? other, double t) =>
      other == null || t < 0.5 ? this : other;

  @override
  bool operator ==(Object other) =>
      other is ThemeMotif &&
      other.preset == preset &&
      other.tone == tone &&
      other.intensity == intensity &&
      other.seed == seed &&
      _sameShapes(other.shapes, shapes) &&
      other.density == density &&
      other.size == size &&
      other.rotate == rotate &&
      other.fill == fill &&
      other.moonPosition == moonPosition;

  @override
  int get hashCode => Object.hash(
    preset,
    tone,
    intensity,
    seed,
    Object.hashAll(shapes),
    density,
    size,
    rotate,
    fill,
    moonPosition,
  );
}

bool _sameShapes(List<String> a, List<String> b) =>
    a.length == b.length &&
    Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);
