import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/selection/choice_field_parts.dart';

/// The parameters every choice field of this package shares.
///
/// Internal, like `TextFieldBase`: a field extends it, forwards the shared
/// parameters with `super.` and builds its `FormField` with [buildChoice],
/// which adds the required check, the helper text and the announced error.
///
/// [V] is the value as the callbacks see it: `bool` for a checkbox, a `Set`
/// for a group (never null, empty means nothing chosen), `T?` for a select.
abstract class ChoiceFieldBase<V> extends StatelessWidget {
  /// Creates the shared parameters.
  const new({
    required this.label,
    this.initialValue,
    this.focusNode,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.required = false,
    this.helperText,
    super.key,
  });

  /// The label, tappable, and read by screen readers.
  final String label;

  /// The value the field starts with, and returns to on `Form.reset`.
  final V? initialValue;

  /// The focus node of the control.
  final FocusNode? focusNode;

  /// Called with the new value at every change.
  final ValueChanged<V>? onChanged;

  /// Called by `FormState.save` with the value.
  final FormFieldSetter<V>? onSaved;

  /// An extra validator, run after the required check.
  final FormFieldValidator<V>? validator;

  /// When to validate; `null` follows the enclosing [Form].
  final AutovalidateMode? autovalidateMode;

  /// Whether the field accepts input. A disabled field is never validated
  /// and shows no error.
  final bool enabled;

  /// Whether an empty value (see [isEmpty]) is an error.
  final bool required;

  /// A hint shown under the field while there is no error.
  final String? helperText;

  /// Whether [value] counts as nothing chosen. `null` always does.
  @protected
  bool isEmpty(V value) => value == null;

  /// Whether the field is a group of options named by [label]. A group shows
  /// [label] as a visible title and exposes it as the label of a container
  /// node holding one node per option (with the error or helper text as its
  /// hint), instead of merging everything into one node.
  @protected
  bool get isGroup => false;

  /// The `FormField` of this field. [builder] draws the choice itself from
  /// the state and reports a change through [change].
  @protected
  Widget buildChoice(
    BuildContext context, {
    required Widget Function(BuildContext context, FormFieldState<V> state)
    builder,
  }) {
    final requiredMessage = required
        ? context.materialL10n.fieldsRequired
        : null;
    final extra = validator;
    String? validate(V? value) {
      if (requiredMessage != null && (value == null || isEmpty(value))) {
        return requiredMessage;
      }
      return extra?.call(value as V);
    }

    return FormField<V>(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: enabled ? validate : (_) => null,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      builder: (state) {
        final error = enabled ? state.errorText : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGroup)
              ChoiceGroupBody(
                label: label,
                hint: error ?? helperText,
                hasError: error != null,
                child: builder(state.context, state),
              )
            else
              // The error, or the helper text, is the hint of the control, so
              // the focused control reads label, state, then it.
              MergeSemantics(
                child: Semantics(
                  hint: error ?? helperText,
                  // Its own Material, so a coloured ancestor neither hides
                  // the ink splashes nor trips the ListTile assertion.
                  child: Material(
                    type: MaterialType.transparency,
                    child: builder(state.context, state),
                  ),
                ),
              ),
            ChoiceFooter(
              helperText: helperText,
              errorText: error,
              // A group's helper text is already the hint of its container.
              excludeHelper: isGroup,
            ),
          ],
        );
      },
    );
  }

  /// Reports [value] to the form and to [onChanged].
  @protected
  void change(FormFieldState<V> state, V value) {
    state.didChange(value);
    onChanged?.call(value);
  }
}
