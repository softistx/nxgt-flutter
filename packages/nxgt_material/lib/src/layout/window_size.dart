import 'package:flutter/widgets.dart';

/// The Material 3 window size classes, by the width of the window.
///
/// Compact is a phone in portrait, medium a tablet in portrait or a foldable,
/// expanded a tablet in landscape or a small desktop window, large and
/// extraLarge a desktop. Read it with `context.windowSize`, or turn a width
/// into one with [WindowSize.fromWidth].
enum WindowSize {
  /// Under 600 logical pixels.
  compact(0),

  /// 600 up to 840.
  medium(Breakpoints.medium),

  /// 840 up to 1200.
  expanded(Breakpoints.expanded),

  /// 1200 up to 1600.
  large(Breakpoints.large),

  /// 1600 and wider.
  extraLarge(Breakpoints.extraLarge);

  new(this.minWidth);

  /// The smallest width, in logical pixels, of this class.
  final double minWidth;

  /// The class of a window [width] logical pixels wide.
  static WindowSize fromWidth(double width) {
    var found = compact;
    for (final size in values) {
      if (width >= size.minWidth) found = size;
    }
    return found;
  }

  /// Whether this class is [other] or wider.
  bool isAtLeast(WindowSize other) => index >= other.index;
}

/// The widths, in logical pixels, where a window changes class.
///
/// The Material 3 values, shared with `@nxgt/material`. Prefer
/// `context.windowSize` to comparing a width with these.
abstract final class Breakpoints {
  /// Where a window becomes [WindowSize.medium].
  static const double medium = 600;

  /// Where a window becomes [WindowSize.expanded].
  static const double expanded = 840;

  /// Where a window becomes [WindowSize.large].
  static const double large = 1200;

  /// Where a window becomes [WindowSize.extraLarge].
  static const double extraLarge = 1600;

  /// The width up to which `ListDetailLayout` shows one pane at a time; the
  /// same 648 as `ListDetailsLayout` in `@nxgt/material`.
  static const double singlePane = 648;
}

/// `context.windowSize`.
extension WindowSizeContext on BuildContext {
  /// The size class of the window, rebuilding only when the class changes
  /// through a width change (it listens to the window size alone).
  WindowSize get windowSize =>
      WindowSize.fromWidth(MediaQuery.sizeOf(this).width);
}
