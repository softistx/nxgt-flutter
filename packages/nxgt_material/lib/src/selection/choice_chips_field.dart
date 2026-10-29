import 'package:flutter/material.dart';
import 'package:nxgt_material/src/selection/choice_field_base.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// A single choice among a few options shown as chips, as a form field.
///
/// A titled group of Material 3 `ChoiceChip`s that wrap onto several lines,
/// each padded to a 48 dp touch target on every platform. The value is the
/// chosen option's value, or `null`. Tapping the chosen chip again clears the
/// choice, except when `required`, where it keeps it (a required field never
/// goes back to empty by a tap). Tab reaches the chips; Space and Enter choose
/// the focused one. `ChoiceOption.description` is the chip's tooltip and
/// semantics hint, never visible text. With `required` it is valid only once
/// an option is chosen. Works in a [Form] (validate, save, reset). For several
/// choices use [FilterChipsField]; for a list of rows use `RadioGroupField`.
class ChoiceChipsField<T> extends ChoiceFieldBase<T?> {
  /// Creates a ChoiceChipsField.
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
    assertInOptions(options, initialValue, 'ChoiceChipsField');
    final unique = uniqueOptions(options, 'ChoiceChipsField');
    final firstEnabled = firstEnabledOption(unique, fieldEnabled: enabled);
    return buildChoice(
      context,
      builder: (context, state) {
        return _ChipWrap(
          children: [
            for (final (i, option) in unique.indexed)
              MergeSemantics(
                child: Semantics(
                  inMutuallyExclusiveGroup: true,
                  child: ChoiceChip(
                    label: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    tooltip: option.description,
                    selected: state.value == option.value,
                    onSelected: enabled && option.enabled
                        ? (selected) {
                            if (selected) {
                              change(state, option.value);
                            } else if (!this.required) {
                              change(state, null);
                            }
                          }
                        : null,
                    focusNode: i == firstEnabled ? focusNode : null,
                    showCheckmark: false,
                    materialTapTargetSize: targetStyle.tapTargetSize,
                    visualDensity: VisualDensity.standard,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Several choices among a few options shown as chips, as a form field.
///
/// The multiple-choice sibling of [ChoiceChipsField], on Material 3
/// `FilterChip`s with checkbox-like semantics. The value is a `Set` that is
/// never mutated: every change reports a new unmodifiable set, in the order of
/// the options. Tapping a chip toggles it. With `required` it is valid only
/// once something is chosen. Works in a [Form] (validate, save, reset).
class FilterChipsField<T> extends ChoiceFieldBase<Set<T>> {
  /// Creates a FilterChipsField.
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
    assertSetInOptions(options, initialValue, 'FilterChipsField');
    final unique = uniqueOptions(options, 'FilterChipsField');
    final firstEnabled = firstEnabledOption(unique, fieldEnabled: enabled);
    return buildChoice(
      context,
      builder: (context, state) {
        final chosen = state.value ?? <T>{};
        return _ChipWrap(
          children: [
            for (final (i, option) in unique.indexed)
              FilterChip(
                label: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                tooltip: option.description,
                selected: chosen.contains(option.value),
                onSelected: enabled && option.enabled
                    ? (selected) => change(
                        state,
                        nextChosen(
                          unique,
                          chosen,
                          option.value,
                          chosen: selected,
                        ),
                      )
                    : null,
                focusNode: i == firstEnabled ? focusNode : null,
                materialTapTargetSize: targetStyle.tapTargetSize,
                visualDensity: VisualDensity.standard,
              ),
          ],
        );
      },
    );
  }
}

/// The chips of a field, wrapping onto several lines. Each chip is padded to
/// 48 dp by its tap target size, which already spaces the lines.
class _ChipWrap extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Wrap(spacing: 8, children: children),
    );
  }
}
