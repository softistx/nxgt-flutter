import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The read-only field of a `SelectField` whose tap opens a sheet. Internal,
/// not exported.
class SelectSheetField extends StatelessWidget {
  /// Creates the field.
  const new({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.focusNode,
    required this.errorTheme,
    required this.trailing,
    required this.onOpen,
    super.key,
  });

  /// The visible label.
  final String label;

  /// Holds the text of the chosen option.
  final TextEditingController controller;

  /// Whether the field reacts.
  final bool enabled;

  /// The caller's focus node, if any.
  final FocusNode? focusNode;

  /// The decoration of the error state, `null` for none.
  final InputDecorationThemeData? errorTheme;

  /// The trailing icon.
  final Widget trailing;

  /// Opens the sheet.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): onOpen,
        const SingleActivator(LogicalKeyboardKey.space): onOpen,
        const SingleActivator(LogicalKeyboardKey.arrowDown): onOpen,
      },
      child: Theme(
        data: errorTheme == null
            ? theme
            : theme.copyWith(inputDecorationTheme: errorTheme),
        // One button that opens the sheet; the clear action stays a custom
        // action of the field.
        child: Semantics(
          button: true,
          enabled: enabled,
          label: label,
          value: controller.text,
          onTap: enabled ? onOpen : null,
          child: ExcludeSemantics(
            child: TextField(
              controller: controller,
              readOnly: true,
              enabled: enabled,
              focusNode: focusNode,
              onTap: onOpen,
              mouseCursor: enabled ? SystemMouseCursors.click : null,
              decoration: InputDecoration(
                labelText: label,
                suffixIcon: trailing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
