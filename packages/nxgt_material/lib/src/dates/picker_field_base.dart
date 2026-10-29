import 'package:flutter/material.dart';
import 'package:nxgt_material/src/dates/picker_field_body.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/selection/choice_field_parts.dart';

/// A form field that shows a value as read-only text and opens a picker to
/// change it: the shared base of `DateField`, `TimeField` and
/// `DateRangeField`. Internal, not exported.
///
/// [V] is the picked value. A field builds this widget with [format] (value
/// to text) and [pick] (open the picker), and gets the decorated, focusable,
/// announced control, the 48 dp clear button, the required check and the
/// form behaviour.
class PickerFieldBase<V> extends StatelessWidget {
  /// Creates the field.
  const new({
    required this.label,
    required this.icon,
    required this.format,
    required this.pick,
    required this.clearLabel,
    this.initialValue,
    this.focusNode,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.rangeError,
    this.autovalidateMode,
    this.enabled = true,
    this.required = false,
    this.clearable = true,
    this.helperText,
    this.hintText,
    super.key,
  });

  /// The label, floating above the value, read by screen readers.
  final String label;

  /// The trailing icon that tells what opens.
  final IconData icon;

  /// The text of a value.
  final String Function(BuildContext context, V value) format;

  /// Opens the picker with the `current` value; resolves to the picked value,
  /// or `null` when the user cancelled.
  final Future<V?> Function(BuildContext context, V? current) pick;

  /// The tooltip and screen reader label of the clear button.
  final String clearLabel;

  /// The value the field starts with, and returns to on `Form.reset`.
  final V? initialValue;

  /// The focus node of the control.
  final FocusNode? focusNode;

  /// Called with the new value, `null` when cleared.
  final ValueChanged<V?>? onChanged;

  /// Called by `FormState.save`.
  final FormFieldSetter<V>? onSaved;

  /// An extra validator, run after the required and range checks.
  final FormFieldValidator<V>? validator;

  /// A built-in check of a present value (such as a date range), run after
  /// the required check and before [validator].
  final String? Function(BuildContext context, V value)? rangeError;

  /// When to validate; `null` follows the enclosing [Form].
  final AutovalidateMode? autovalidateMode;

  /// Whether the field accepts input. A disabled field is never validated.
  final bool enabled;

  /// Whether an empty field is an error.
  final bool required;

  /// Whether a value can be cleared.
  final bool clearable;

  /// A hint under the field while there is no error.
  final String? helperText;

  /// A placeholder shown in the empty field.
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final requiredMessage = required
        ? context.materialL10n.fieldsRequired
        : null;
    String? validate(V? value) {
      if (value == null) return requiredMessage;
      return rangeError?.call(context, value) ?? validator?.call(value);
    }

    return FormField<V>(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: enabled ? validate : (_) => null,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      builder: (state) {
        final error = enabled ? state.errorText : null;
        final value = state.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PickerFieldBody(
              label: label,
              icon: icon,
              text: value == null ? null : format(state.context, value),
              hint: error ?? helperText,
              hintText: hintText,
              hasError: error != null,
              enabled: enabled,
              canClear: enabled && clearable && value != null,
              clearLabel: clearLabel,
              focusNode: focusNode,
              onOpen: () async {
                final picked = await pick(state.context, state.value);
                if (picked == null || !state.mounted) return;
                state.didChange(picked);
                onChanged?.call(picked);
              },
              onClear: () {
                state.didChange(null);
                onChanged?.call(null);
              },
            ),
            ChoiceFooter(
              helperText: helperText,
              errorText: error,
              // The helper text is already the hint of the control.
              excludeHelper: true,
            ),
          ],
        );
      },
    );
  }
}
