import 'package:flutter/material.dart';
import 'package:nxgt_material/src/selection/choice_field_base.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// Several choices among a few options, as a form field.
///
/// A titled vertical group of full-width checkbox tiles, each at least 48 dp
/// high with its label and optional description. The value is a `Set` that is
/// never mutated: every change reports a new unmodifiable set, in the order of
/// the options. With
/// `required` it is valid only once something is chosen. Works in a [Form]
/// (validate, save, reset). For a single box use `CheckboxField`.
class CheckboxGroupField<T> extends ChoiceFieldBase<Set<T>> {
  /// Creates a CheckboxGroupField.
  const new({
    required super.label,
    required this.options,
    super.initialValue = const {},
    super.focusNode,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.required,
    super.helperText,
    super.key,
  });

  /// The options, in display order. Values must be unique.
  final List<ChoiceOption<T>> options;

  @override
  bool get isGroup => true;

  @override
  bool isEmpty(Set<T> value) => value.isEmpty;

  @override
  Widget build(BuildContext context) {
    assertSetInOptions(options, initialValue, 'CheckboxGroupField');
    final unique = uniqueOptions(options, 'CheckboxGroupField');
    final firstEnabled = firstEnabledOption(unique, fieldEnabled: enabled);
    return buildChoice(
      context,
      builder: (context, state) {
        final chosen = state.value ?? <T>{};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, option) in unique.indexed)
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: minTarget.height),
                child: CheckboxListTile(
                  value: chosen.contains(option.value),
                  onChanged: enabled && option.enabled
                      ? (checked) => change(
                          state,
                          nextChosen(
                            unique,
                            state.value ?? <T>{},
                            option.value,
                            chosen: checked ?? false,
                          ),
                        )
                      : null,
                  focusNode: i == firstEnabled ? focusNode : null,
                  title: Text(option.label),
                  subtitle: option.description == null
                      ? null
                      : Text(option.description!),
                  controlAffinity: ListTileControlAffinity.leading,
                  visualDensity: VisualDensity.standard,
                  isError: state.hasError && enabled,
                ),
              ),
          ],
        );
      },
    );
  }
}
