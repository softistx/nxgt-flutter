import 'package:flutter/widgets.dart';
import 'package:nxgt_material/src/layout/window_size.dart';

/// The page content of a screen: centred, no wider than [maxWidth], with
/// gutters that grow with the window.
///
/// Prefer it to a hand-made `Padding` and `ConstrainedBox` around a screen's
/// content, so every screen shares the same margins. The gutters are 16 dp on
/// a compact window, 24 on medium and expanded, and 32 on large and
/// extraLarge, the Material 3 margins. It does not scroll: put it inside a
/// scroll view, or give it a scrollable [child].
class PageBody extends StatelessWidget {
  /// Creates a PageBody.
  const new({
    required this.child,
    this.maxWidth = 1200,
    this.gutter,
    super.key,
  });

  /// The page content.
  final Widget child;

  /// The widest the content gets, gutters included; wider windows leave the
  /// rest empty on both sides.
  final double maxWidth;

  /// The side gutter. Defaults to the one of the window's [WindowSize].
  final double? gutter;

  /// The gutter of a [size] window.
  static double gutterFor(WindowSize size) => switch (size) {
    WindowSize.compact => 16,
    WindowSize.medium || WindowSize.expanded => 24,
    WindowSize.large || WindowSize.extraLarge => 32,
  };

  @override
  Widget build(BuildContext context) {
    final side = gutter ?? gutterFor(context.windowSize);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < maxWidth
            ? constraints.maxWidth
            : maxWidth;
        return Align(
          alignment: AlignmentDirectional.topCenter,
          child: SizedBox(
            width: width,
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: side),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
