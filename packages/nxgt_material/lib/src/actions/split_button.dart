import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// A main action with a menu of related actions beside it.
///
/// Material 3 has no split button. Prefer it when one action is the usual
/// choice ("Save") and a few siblings ("Save as draft", "Save and close") are
/// worth keeping one tap away. The main part is a [FilledButton]; the arrow
/// opens a [MenuAnchor] holding [menuChildren], typically [MenuItemButton]s.
/// The arrow stays usable when [onPressed] is null.
class SplitButton extends StatelessWidget {
  /// Creates a SplitButton.
  const new({
    required this.label,
    required this.onPressed,
    required this.menuChildren,
    this.icon,
    this.menuTooltip,
    super.key,
  });

  /// The text of the main action, also read by screen readers.
  final String label;

  /// The main action; `null` disables the main part only.
  final VoidCallback? onPressed;

  /// The menu entries, usually [MenuItemButton]s.
  final List<Widget> menuChildren;

  /// An icon shown before the label.
  final Widget? icon;

  /// Overrides the localized "More options" tooltip of the arrow.
  final String? menuTooltip;

  static const _outer = Radius.circular(20);
  static const _inner = Radius.circular(4);
  static const _mainShape = RoundedRectangleBorder(
    borderRadius: BorderRadiusDirectional.horizontal(
      start: _outer,
      end: _inner,
    ),
  );
  static const _arrowShape = RoundedRectangleBorder(
    borderRadius: BorderRadiusDirectional.horizontal(
      start: _inner,
      end: _outer,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final tooltip = menuTooltip ?? context.materialL10n.actionsMoreOptions;
    final text = Text(label);
    const mainStyle = ButtonStyle(shape: WidgetStatePropertyAll(_mainShape));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon == null)
          FilledButton(onPressed: onPressed, style: mainStyle, child: text)
        else
          FilledButton.icon(
            onPressed: onPressed,
            style: mainStyle,
            icon: icon,
            label: text,
          ),
        const SizedBox(width: 2),
        MenuAnchor(
          menuChildren: menuChildren,
          builder: (context, controller, _) => IconButton.filled(
            tooltip: tooltip,
            style: const ButtonStyle(
              shape: WidgetStatePropertyAll(_arrowShape),
            ),
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
            icon: Icon(
              controller.isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            ),
          ),
        ),
      ],
    );
  }
}
