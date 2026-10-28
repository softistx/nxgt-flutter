import 'package:flutter/material.dart';
import 'package:nxgt_material/src/theme/motif.dart';
import 'package:nxgt_material/src/theme/oklch.dart';
import 'package:nxgt_material/src/theme/radius_scale.dart';
import 'package:nxgt_material/src/theme/theme_fonts.dart';
import 'package:nxgt_material/src/theme/tone_seed.dart';
import 'package:nxgt_material/src/theme/tones.dart';

/// A theme as data: the Dart `defineTheme` of `@nxgt/material`.
///
/// Give it a [primary] seed colour; [light] and [dark] return a Material 3
/// [ThemeData] built on `ColorScheme.fromSeed`, carrying the [Tones],
/// [RadiusScale], [ThemeFonts] and [ThemeMotif] extensions. The presets in
/// `ThemePresets` are specs too, and [copyWith] extends one:
///
/// ```dart
/// final school = ThemePresets.ocean.copyWith(
///   name: 'school',
///   tones: {'maths': ToneSeed(Oklch(0.5, 0.14, 300))},
/// );
/// MaterialApp(theme: school.light(), darkTheme: school.dark());
/// ```
@immutable
class ThemeSpec {
  /// Creates a theme from a [name] and a [primary] seed.
  ///
  /// [tones] may not use a name in [reservedToneNames], except `success`,
  /// `info` and `warning`, which it replaces.
  const new({
    required this.name,
    required this.primary,
    this.label,
    this.secondary,
    this.tertiary,
    this.tones = const {},
    this.radius = const RadiusScale(),
    this.fonts = const ThemeFonts(),
    this.motif = ThemeMotif.none,
    this.suggestedMode = ThemeMode.system,
  });

  /// The id of the theme: `[a-z][a-z0-9-]*`, as in `@nxgt/material`.
  final String name;

  /// A name for a theme picker; [name] when `null`.
  final String? label;

  /// The seed of the Material 3 colour scheme.
  final Oklch primary;

  /// The secondary seed; the scheme's secondary when `null`.
  final ToneSeed? secondary;

  /// The tertiary seed; the scheme's tertiary when `null`.
  final ToneSeed? tertiary;

  /// The app's tones by name, and the `success`, `info` and `warning` seeds
  /// it replaces.
  final Map<String, ToneSeed> tones;

  /// The corner radii.
  final RadiusScale radius;

  /// The font families.
  final ThemeFonts fonts;

  /// The background and icon motif.
  final ThemeMotif motif;

  /// The mode to start in when the user has not chosen one.
  final ThemeMode suggestedMode;

  /// The text for a theme picker.
  String get displayName => label ?? name;

  /// This spec with the given parts replaced: how a theme extends another.
  ThemeSpec copyWith({
    String? name,
    String? label,
    Oklch? primary,
    ToneSeed? secondary,
    ToneSeed? tertiary,
    Map<String, ToneSeed>? tones,
    RadiusScale? radius,
    ThemeFonts? fonts,
    ThemeMotif? motif,
    ThemeMode? suggestedMode,
  }) => ThemeSpec(
    name: name ?? this.name,
    label: label ?? this.label,
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    tertiary: tertiary ?? this.tertiary,
    tones: tones ?? this.tones,
    radius: radius ?? this.radius,
    fonts: fonts ?? this.fonts,
    motif: motif ?? this.motif,
    suggestedMode: suggestedMode ?? this.suggestedMode,
  );

  /// The light [ThemeData].
  ThemeData light() => data(Brightness.light);

  /// The dark [ThemeData].
  ThemeData dark() => data(Brightness.dark);

  /// The [ThemeData] for [brightness].
  ThemeData data(Brightness brightness) {
    assert(
      RegExp(r'^[a-z][a-z0-9-]*$').hasMatch(name),
      'A theme name is [a-z][a-z0-9-]*, got "$name".',
    );
    assert(
      tones.keys.every(
        (k) => !reservedToneNames.contains(k) || _status.contains(k),
      ),
      'A tone name cannot be one of $reservedToneNames (only $_status may be '
      'replaced).',
    );
    var scheme = ColorScheme.fromSeed(
      seedColor: primary.toColor(),
      brightness: brightness,
    );
    final toneSet = Tones.fromScheme(
      scheme,
      secondary: secondary,
      tertiary: tertiary,
      tones: tones,
    );
    scheme = scheme.copyWith(
      secondary: toneSet.secondary.color,
      onSecondary: toneSet.secondary.onColor,
      secondaryContainer: toneSet.secondary.container,
      onSecondaryContainer: toneSet.secondary.onContainer,
      tertiary: toneSet.tertiary.color,
      onTertiary: toneSet.tertiary.onColor,
      tertiaryContainer: toneSet.tertiary.container,
      onTertiaryContainer: toneSet.tertiary.onContainer,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fonts.sans,
    );
    final heading = fonts.heading;
    return base.copyWith(
      textTheme: heading == null ? null : _headings(base.textTheme, heading),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.item),
        ),
      ),
      extensions: [toneSet, radius, fonts, motif],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ThemeSpec &&
      other.name == name &&
      other.label == label &&
      other.primary == primary &&
      other.secondary == secondary &&
      other.tertiary == tertiary &&
      _sameTones(other.tones, tones) &&
      other.radius == radius &&
      other.fonts == fonts &&
      other.motif == motif &&
      other.suggestedMode == suggestedMode;

  @override
  int get hashCode => Object.hash(
    name,
    label,
    primary,
    secondary,
    tertiary,
    Object.hashAll(tones.entries.map((e) => Object.hash(e.key, e.value))),
    radius,
    fonts,
    motif,
    suggestedMode,
  );
}

const _status = {'success', 'info', 'warning'};

bool _sameTones(Map<String, ToneSeed> a, Map<String, ToneSeed> b) =>
    a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

TextTheme _headings(TextTheme t, String family) => t.copyWith(
  displayLarge: t.displayLarge?.copyWith(fontFamily: family),
  displayMedium: t.displayMedium?.copyWith(fontFamily: family),
  displaySmall: t.displaySmall?.copyWith(fontFamily: family),
  headlineLarge: t.headlineLarge?.copyWith(fontFamily: family),
  headlineMedium: t.headlineMedium?.copyWith(fontFamily: family),
  headlineSmall: t.headlineSmall?.copyWith(fontFamily: family),
);
