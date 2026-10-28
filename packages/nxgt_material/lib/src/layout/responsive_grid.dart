import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Tiles in a grid whose columns follow the width it is given.
///
/// As many columns as fit tiles at least [minItemWidth] wide, so a board of
/// small tiles gains columns on a wide window instead of stretching, as
/// `ResponsiveGrid` of `@nxgt/material` does. The tiles share the width
/// equally; their heights are their own. It sizes to its content, so it sits
/// inside a scroll view. It adds no semantics: each tile keeps its own. For a
/// long lazy list use a `GridView` with
/// `SliverGridDelegateWithMaxCrossAxisExtent` instead.
class ResponsiveGrid extends StatelessWidget {
  /// Creates a ResponsiveGrid.
  const new({
    required this.children,
    this.minItemWidth = 224,
    this.spacing = 8,
    super.key,
  }) : assert(minItemWidth > 0, 'minItemWidth must be positive');

  /// The tiles.
  final List<Widget> children;

  /// The narrowest a tile gets, in logical pixels; 224 is 14 rem.
  final double minItemWidth;

  /// The space between tiles, in both directions.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(
          constraints.maxWidth,
          minItemWidth,
          spacing,
        );
        final tile = constraints.maxWidth.isFinite
            ? (constraints.maxWidth - spacing * (columns - 1)) / columns
            : minItemWidth;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: tile, child: child),
          ],
        );
      },
    );
  }
}

/// How many columns of at least [minItemWidth] fit in [width].
int _columnsFor(double width, double minItemWidth, double spacing) {
  if (!width.isFinite) return 1;
  final fit = ((width + spacing) / (minItemWidth + spacing)).floor();
  return math.max(1, fit);
}
