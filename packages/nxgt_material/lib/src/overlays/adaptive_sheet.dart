import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/layout/window_size.dart';

const _minTarget = Size.square(48);

/// The width of the side sheet, in logical pixels, on a window wide enough.
const _sideSheetWidth = 400.0;

/// The share of the window height a bottom sheet may take.
const _maxHeightFactor = 0.9;

/// The content of a sheet: a header (the title and a close button) above a
/// body that scrolls.
///
/// Prefer `context.showAdaptiveSheet` to show it. The widget draws no
/// surface and no handle: the route that shows it adds them. It is public to
/// be placed in a Widgetbook use case or a golden test, and needs a `Material`
/// ancestor for the close button.
///
/// The title is a semantics header. The close button pops the route with no
/// value.
class AdaptiveSheet extends StatelessWidget {
  /// Creates the content of a sheet.
  const new({required this.title, required this.child, super.key})
    : assert(title != '', 'AdaptiveSheet.title must not be empty.');

  /// The title, also the name of the sheet for screen readers.
  final String title;

  /// The body, below the header. It scrolls when it is taller than the room.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 24, end: 8),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.titleLarge),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: context.materialL10n.actionsClose,
                onPressed: () => Navigator.of(context).maybePop(),
                style: _closeStyle,
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 24),
            child: child,
          ),
        ),
      ],
    );
  }
}

const _closeStyle = ButtonStyle(
  minimumSize: WidgetStatePropertyAll(_minTarget),
  tapTargetSize: MaterialTapTargetSize.padded,
  visualDensity: VisualDensity.standard,
);

/// The sheet in the route: names the route and keeps the content clear of the
/// keyboard.
class _SheetBody extends StatelessWidget {
  const new({required this.title, required this.builder});

  final String title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: title,
      explicitChildNodes: true,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: AdaptiveSheet(
          title: title,
          child: Builder(builder: builder),
        ),
      ),
    );
  }
}

/// `context.showAdaptiveSheet`, shows content in a sheet that fits the window.
extension AdaptiveSheetContext on BuildContext {
  /// Shows the content of [builder] under [title] in a modal sheet and
  /// returns the value it was popped with, or `null` when the user closed it
  /// with the close button, Escape, a tap on the barrier or the back gesture.
  ///
  /// "Adaptive" here means the window size, not the platform (unlike Flutter's
  /// `showAdaptiveDialog`). On a compact window (under 600 dp) the content is
  /// in a bottom sheet with a drag handle, up to 90 % of the height, kept
  /// above the keyboard. From the medium size up it is in a side sheet on the
  /// end edge (the right in left-to-right text, the left in right-to-left),
  /// 400 dp wide and full height. The size is read when the sheet opens.
  ///
  /// Pop the sheet with `Navigator.pop(context, value)` from the builder's
  /// context to return a value. Focus stays in the sheet while it is open and
  /// returns to the control that opened it.
  ///
  /// ```dart
  /// final color = await context.showAdaptiveSheet<Color>(
  ///   title: 'Pick a color',
  ///   builder: (context) => ColorList(
  ///     onPick: (color) => Navigator.pop(context, color),
  ///   ),
  /// );
  /// ```
  ///
  /// Throws without a `Navigator` above (any `MaterialApp` provides one).
  Future<T?> showAdaptiveSheet<T>({
    required String title,
    required WidgetBuilder builder,
  }) {
    final body = _SheetBody(title: title, builder: builder);
    if (windowSize == WindowSize.compact) {
      return showModalBottomSheet<T>(
        context: this,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(this).height * _maxHeightFactor,
        ),
        builder: (_) => body,
      );
    }
    final theme = Theme.of(this);
    final width = MediaQuery.sizeOf(this).width;
    return showGeneralDialog<T>(
      context: this,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(this).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, _) => Theme(
        data: theme,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: SizedBox(
            width: width < _sideSheetWidth ? width : _sideSheetWidth,
            height: double.infinity,
            child: Material(
              color: theme.colorScheme.surfaceContainerLow,
              elevation: 1,
              child: SafeArea(child: body),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) {
        final rtl = Directionality.of(context) == TextDirection.rtl;
        return SlideTransition(
          position: Tween(
            begin: Offset(rtl ? -1 : 1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }
}
