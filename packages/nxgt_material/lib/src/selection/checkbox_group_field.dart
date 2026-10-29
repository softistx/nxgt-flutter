import 'package:flutter/material.dart';
import 'package:nxgt_material/src/selection/choice_field_base.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// Several choices among a few options, as a form field.
///
/// A titled vertical group of full-width checkbox tiles, each at least 48 dp
/// high with its label and optional description. The value is a `Set` that is
/// never mutated: every change reports a new unmodifiable set. With
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
    assert(options.isNotEmpty, 'CheckboxGroupField.options must not be empty.');
    assert(
      options.map((o) => o.value).toSet().length == options.length,
      'CheckboxGroupField.options must have unique values.',
    );
    assert(
      (initialValue ?? const {}).every((v) => options.any((o) => o.value == v)),
      'CheckboxGroupField.initialValue must only hold values of the options.',
    );
    final seen = <T>{};
    final unique = [
      for (final option in options)
        if (seen.add(option.value)) option,
    ];
    return buildChoice(
      context,
      builder: (context, state) {
        final chosen = state.value ?? <T>{};
        var focusAssigned = false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in unique)
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: minTarget.height),
                child: CheckboxListTile(
                  value: chosen.contains(option.value),
                  onChanged: enabled && option.enabled
                      ? (checked) => change(
                          state,
                          Set<T>.unmodifiable({
                            for (final v in state.value ?? <T>{})
                              if (v != option.value) v,
                            if (checked ?? false) option.value,
                          }),
                        )
                      : null,
                  focusNode: (focusAssigned || !(enabled && option.enabled))
                      ? null
                      : (focusAssigned = true)
                      ? focusNode
                      : null,
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
