import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// The corner radii of a theme, in logical pixels.
///
/// The scale is Material 3 Expressive's (xs 4 to xxl 48); [base] and [item]
/// are the two the theme itself sets: `--radius` and `--nxgt-item-radius` in
/// `@nxgt/material`. Read it with `context.radii`.
@immutable
class RadiusScale extends ThemeExtension<RadiusScale> {
  /// Creates a scale; every step defaults to Material 3 Expressive's.
  const new({
    this.base = 10,
    double? item,
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.lgPlus = 20,
    this.xl = 28,
    this.xlPlus = 32,
    this.xxl = 48,
  }) : item = item ?? base;

  /// The theme's own radius: cards, inputs and the like.
  final double base;

  /// The radius of an item in a list or a menu; [base] unless set.
  final double item;

  /// 4.
  final double xs;

  /// 8.
  final double sm;

  /// 12.
  final double md;

  /// 16.
  final double lg;

  /// 20.
  final double lgPlus;

  /// 28.
  final double xl;

  /// 32.
  final double xlPlus;

  /// 48.
  final double xxl;

  /// The steps with their names, smallest first.
  Map<String, double> get steps => {
    'xs': xs,
    'sm': sm,
    'md': md,
    'lg': lg,
    'lg-plus': lgPlus,
    'xl': xl,
    'xl-plus': xlPlus,
    'xxl': xxl,
  };

  @override
  RadiusScale copyWith({
    double? base,
    double? item,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? lgPlus,
    double? xl,
    double? xlPlus,
    double? xxl,
  }) => RadiusScale(
    base: base ?? this.base,
    item: item ?? this.item,
    xs: xs ?? this.xs,
    sm: sm ?? this.sm,
    md: md ?? this.md,
    lg: lg ?? this.lg,
    lgPlus: lgPlus ?? this.lgPlus,
    xl: xl ?? this.xl,
    xlPlus: xlPlus ?? this.xlPlus,
    xxl: xxl ?? this.xxl,
  );

  @override
  RadiusScale lerp(RadiusScale? other, double t) {
    if (other == null) return this;
    double mix(double a, double b) => lerpDouble(a, b, t)!;
    return RadiusScale(
      base: mix(base, other.base),
      item: mix(item, other.item),
      xs: mix(xs, other.xs),
      sm: mix(sm, other.sm),
      md: mix(md, other.md),
      lg: mix(lg, other.lg),
      lgPlus: mix(lgPlus, other.lgPlus),
      xl: mix(xl, other.xl),
      xlPlus: mix(xlPlus, other.xlPlus),
      xxl: mix(xxl, other.xxl),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RadiusScale &&
      other.base == base &&
      other.item == item &&
      other.xs == xs &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.lgPlus == lgPlus &&
      other.xl == xl &&
      other.xlPlus == xlPlus &&
      other.xxl == xxl;

  @override
  int get hashCode =>
      Object.hash(base, item, xs, sm, md, lg, lgPlus, xl, xlPlus, xxl);
}
