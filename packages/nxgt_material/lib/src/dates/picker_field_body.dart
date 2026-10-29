import 'package:flutter/material.dart';
import 'package:nxgt_material/src/selection/select_menu.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// The control of a `PickerFieldBase`: a decorated read-only value that opens
/// a picker, with a clear button beside it. Internal, not exported.
///
/// The field is one semantics node (button, label, value, and the error or
/// helper text as its hint); the clear button stays its own node.
class PickerFieldBody extends StatefulWidget {
  /// Creates the control.
  const new({
    required this.label,
    required this.icon,
    required this.text,
    required this.hint,
    required this.hintText,
    required this.hasError,
    required this.enabled,
    required this.canClear,
    required this.clearLabel,
    required this.focusNode,
    required this.onOpen,
    required this.onClear,
    super.key,
  });

  /// The visible label.
  final String label;

  /// The trailing icon.
  final IconData icon;

  /// The formatted value, `null` when empty.
  final String? text;

  /// The error, or the helper text, read as the hint of the node.
  final String? hint;

  /// The placeholder of an empty field.
  final String? hintText;

  /// Whether to draw the error state.
  final bool hasError;

  /// Whether the control reacts.
  final bool enabled;

  /// Whether the clear button shows.
  final bool canClear;

  /// The tooltip of the clear button.
  final String clearLabel;

  /// The caller's focus node, if any.
  final FocusNode? focusNode;

  /// Opens the picker.
  final VoidCallback onOpen;

  /// Clears the value.
  final VoidCallback onClear;

  @override
  State<PickerFieldBody> createState() => _PickerFieldBodyState();
}

class _PickerFieldBodyState extends State<PickerFieldBody> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = widget.text;
    final enabled = widget.enabled;
    final errorTheme = widget.hasError ? selectErrorTheme(context) : null;
    final decoration = InputDecoration(
      labelText: widget.label,
      hintText: widget.hintText,
      floatingLabelBehavior: widget.hintText == null
          ? null
          : FloatingLabelBehavior.always,
      enabled: enabled,
      // Room for the clear button, which sits above the decorator.
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.canClear) SizedBox.fromSize(size: minTarget),
          Icon(widget.icon),
          const SizedBox(width: 12),
        ],
      ),
      // A null `constraints` does not pin the suffix; this does.
      suffixIconConstraints: const BoxConstraints(),
    ).applyDefaults(errorTheme ?? theme.inputDecorationTheme);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Semantics(
            container: true,
            button: true,
            enabled: enabled,
            focusable: enabled,
            focused: _focused,
            label: widget.label,
            value: text,
            hint: widget.hint,
            onTap: enabled ? widget.onOpen : null,
            child: ExcludeSemantics(
              child: InkWell(
                onTap: enabled ? widget.onOpen : null,
                focusNode: widget.focusNode,
                onFocusChange: (focused) => setState(() => _focused = focused),
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: decoration,
                  isEmpty: text == null,
                  isFocused: _focused,
                  child: text == null
                      ? null
                      : Text(
                          text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: enabled
                                ? null
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.38,
                                  ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (widget.canClear)
            PositionedDirectional(
              end: 36,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: widget.clearLabel,
                  onPressed: widget.onClear,
                  style: targetStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
