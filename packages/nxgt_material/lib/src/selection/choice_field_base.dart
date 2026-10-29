import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nxgt_material/src/feedback/live_region.dart';

/// The parameters every choice field of this package shares.
///
/// Internal, like `TextFieldBase`: a field extends it, forwards the shared
/// parameters with `super.` and builds its `FormField` with [buildChoice],
/// which adds the helper text and the announced error below the field.
abstract class ChoiceFieldBase<T> extends StatelessWidget {
  /// Creates the shared parameters.
  const new({
    required this.label,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.helperText,
    super.key,
  });

  /// The label, tappable, and read by screen readers.
  final String label;

  /// The value the field starts with, and returns to on `Form.reset`.
  final T? initialValue;

  /// Called with the new value at every change.
  final ValueChanged<T?>? onChanged;

  /// Called by `FormState.save` with the value.
  final FormFieldSetter<T>? onSaved;

  /// An extra validator, run after the built-in ones.
  final FormFieldValidator<T>? validator;

  /// When to validate; `null` follows the enclosing [Form].
  final AutovalidateMode? autovalidateMode;

  /// Whether the field accepts input.
  final bool enabled;

  /// A hint shown under the field while there is no error.
  final String? helperText;

  /// The `FormField` of this field. [composed] is its validator once the
  /// built-in ones are added to [validator]; [builder] draws the choice
  /// itself from the state and reports a change through
  /// `FormFieldState.didChange`.
  @protected
  Widget buildChoice({
    required FormFieldValidator<T> composed,
    required Widget Function(BuildContext context, FormFieldState<T> state)
    builder,
  }) {
    return FormField<T>(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: composed,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          builder(state.context, state),
          _Footer(helperText: helperText, errorText: state.errorText),
        ],
      ),
    );
  }

  /// Reports [value] to the form and to [onChanged].
  @protected
  void change(FormFieldState<T> state, T? value) {
    state.didChange(value);
    onChanged?.call(value);
  }
}

/// The helper text, replaced by the announced error when there is one.
class _Footer extends StatelessWidget {
  const new({required this.helperText, required this.errorText});

  final String? helperText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = errorText;
    final helper = helperText;
    if (error != null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
        // The role and the live region sit on two nodes: Flutter refuses
        // both on one.
        child: Semantics(
          container: true,
          role: SemanticsRole.alert,
          child: Semantics(
            container: true,
            liveRegion: liveRegionUnderRole,
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      );
    }
    if (helper == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: Text(
        helper,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
