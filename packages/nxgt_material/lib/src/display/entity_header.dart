import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/layout/window_size.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';
import 'package:nxgt_material/src/theme/tone_colors.dart';

/// An action of an [EntityHeader]: a [label], an optional [icon] and what
/// happens on [onPressed].
///
/// The header draws it as a button from the medium window size and as an item
/// of its "More options" menu on compact. A [destructive] action (delete,
/// archive) is tinted with the error tone, never by colour alone: keep the
/// label explicit.
class EntityAction {
  /// Creates an EntityAction.
  const new({
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
  }) : assert(label != '', 'EntityAction.label must not be empty.');

  /// The text of the button or menu item, also read by screen readers.
  final String label;

  /// Called when the action is chosen; `null` disables it.
  final VoidCallback? onPressed;

  /// An icon drawn before the label.
  final IconData? icon;

  /// Whether the action removes or breaks something; it is drawn with the
  /// error tone.
  final bool destructive;
}

/// The text scale above which the actions fold into the menu, whatever the
/// window size, because buttons would not fit beside the title.
const _inlineMaxTextScale = 1.5;

const _minTarget = Size.square(48);

/// The error tone while enabled; `null` when disabled, so the theme's
/// disabled look applies.
WidgetStateProperty<Color?> _whenEnabled(Color color) =>
    WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled) ? null : color,
    );

ButtonStyle _actionStyle(EntityAction action, ToneColors error) => ButtonStyle(
  minimumSize: const WidgetStatePropertyAll(_minTarget),
  tapTargetSize: MaterialTapTargetSize.padded,
  visualDensity: VisualDensity.standard,
  backgroundColor: action.destructive ? _whenEnabled(error.container) : null,
  foregroundColor: action.destructive ? _whenEnabled(error.onContainer) : null,
  iconColor: action.destructive ? _whenEnabled(error.onContainer) : null,
);

Widget _actionButton(EntityAction action, ToneColors error) {
  final style = _actionStyle(action, error);
  final icon = action.icon;
  final label = Text(action.label);
  if (icon == null) {
    return OutlinedButton(
      onPressed: action.onPressed,
      style: style,
      child: label,
    );
  }
  return OutlinedButton.icon(
    onPressed: action.onPressed,
    style: style,
    icon: Icon(icon),
    label: label,
  );
}

Widget _menuItem(EntityAction action, ToneColors error) => MenuItemButton(
  onPressed: action.onPressed,
  leadingIcon: action.icon == null ? null : Icon(action.icon),
  style: _actionStyle(action, error),
  child: Text(action.label),
);

/// The heading of a record page or a sheet: a [title], a muted [subtitle], a
/// [leading] widget, a [status] and the page's [actions].
///
/// The title is a semantics header, drawn in the theme's `headlineSmall`. The
/// [leading] is typically a `UserAvatar` and the [status] a `StatusIndicator`;
/// both are plain widgets, so the header is not coupled to either. From the
/// medium window size ([WindowSize.medium], read through `context.windowSize`)
/// the [actions] are buttons beside the text; on compact, or when the text
/// scale is above 1.5, they fold into a "More options" menu so the title keeps
/// the room. Long text wraps. It is not an `AppBar` (the screen's bar) nor a
/// `ListTile` (a row in a list).
class EntityHeader extends StatelessWidget {
  /// Creates an EntityHeader.
  const new({
    required this.title,
    this.subtitle,
    this.leading,
    this.status,
    this.actions = const [],
    super.key,
  });

  /// The name of the entity, a semantics header.
  final String title;

  /// A muted line under the [title], such as an email or a reference.
  final String? subtitle;

  /// A widget before the text, typically a `UserAvatar`.
  final Widget? leading;

  /// A widget under the text, typically a `StatusIndicator`.
  final Widget? status;

  /// What can be done with the entity. An action with an empty label is left
  /// out in a release build.
  final List<EntityAction> actions;

  @override
  Widget build(BuildContext context) {
    final shown = [
      for (final action in actions)
        if (action.label.isNotEmpty) action,
    ];
    final inline =
        context.windowSize.isAtLeast(WindowSize.medium) &&
        MediaQuery.textScalerOf(context).scale(14) / 14 <= _inlineMaxTextScale;
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          ?leading,
          Expanded(child: _text(context)),
          if (shown.isNotEmpty)
            if (inline)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth.isFinite
                      ? constraints.maxWidth / 2
                      : double.infinity,
                ),
                child: _buttons(context, shown),
              )
            else
              _overflow(context, shown),
        ],
      ),
    );
  }

  Widget _text(BuildContext context) {
    final theme = Theme.of(context);
    final sub = subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (sub != null && sub.isNotEmpty)
          Text(
            sub,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (status != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 4),
            child: status,
          ),
      ],
    );
  }

  Widget _buttons(BuildContext context, List<EntityAction> shown) {
    final error = context.tones.error;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [for (final action in shown) _actionButton(action, error)],
    );
  }

  Widget _overflow(BuildContext context, List<EntityAction> shown) {
    final error = context.tones.error;
    final tooltip = context.materialL10n.actionsMoreOptions;
    return MenuAnchor(
      menuChildren: [for (final action in shown) _menuItem(action, error)],
      builder: (context, controller, _) => IconButton(
        tooltip: tooltip,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        style: IconButton.styleFrom(
          minimumSize: _minTarget,
          tapTargetSize: MaterialTapTargetSize.padded,
          visualDensity: VisualDensity.standard,
        ),
        icon: const Icon(Icons.more_vert),
      ),
    );
  }
}
