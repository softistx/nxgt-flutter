import 'package:flutter/widgets.dart';

/// A [SafeArea] whose horizontal sides are given as start and end, so they
/// follow the text direction instead of the physical left and right.
class SafeSides extends StatelessWidget {
  /// Creates a SafeSides.
  const new({
    required this.child,
    this.start = true,
    this.end = true,
    this.top = true,
    this.bottom = true,
    super.key,
  });

  /// Whether to keep clear of the inset at the start side.
  final bool start;

  /// Whether to keep clear of the inset at the end side.
  final bool end;

  /// Whether to keep clear of the top inset.
  final bool top;

  /// Whether to keep clear of the bottom inset.
  final bool bottom;

  /// The content kept inside the safe sides.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SafeArea(
      left: rtl ? end : start,
      right: rtl ? start : end,
      top: top,
      bottom: bottom,
      child: child,
    );
  }
}
