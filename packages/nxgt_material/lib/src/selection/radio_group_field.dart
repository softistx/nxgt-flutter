import 'package:flutter/material.dart';
import 'package:nxgt_material/src/selection/choice_field_base.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// A single choice among a few options, as a form field.
///
/// A titled vertical group of full-width tiles, each at least 48 dp high with
/// its label and optional description, on Flutter's `RadioGroup`: the arrow
/// keys move the choice inside the group and Tab leaves it. With `required`
/// it is valid only once an option is chosen. Works in a [Form] (validate,
/// save, reset). For a long list use a select; for a lone option without form
/// behaviour use Material's `RadioListTile`.
class RadioGroupField<T> extends ChoiceFieldBase<T?> {
  /// Creates a RadioGroupField.
  const new({
    required super.label,
    required this.options,
    super.initialValue,
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
  Widget build(BuildContext context) {
    assert(options.isNotEmpty, 'RadioGroupField.options must not be empty.');
    assert(
      options.map((o) => o.value).toSet().length == options.length,
      'RadioGroupField.options must have unique values.',
    );
    assert(
      initialValue == null || options.any((o) => o.value == initialValue),
      'RadioGroupField.initialValue must be one of the options.',
    );
    final seen = <T>{};
    final unique = [
      for (final option in options)
        if (seen.add(option.value)) option,
    ];
    return buildChoice(
      context,
      builder: (context, state) {
        var focusAssigned = false;
        return RadioGroup<T>(
          groupValue: state.value,
          onChanged: (value) {
            if (enabled) change(state, value);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in unique)
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minTarget.height),
                  child: RadioListTile<T>(
                    value: option.value,
                    enabled: enabled && option.enabled,
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
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
