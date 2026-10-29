/// One choice offered by a group, chip set or select of this package.
class ChoiceOption<T> {
  /// Creates an option.
  const new({
    required this.value,
    required this.label,
    this.description,
    this.enabled = true,
  });

  /// The value reported when the option is chosen. Unique in its list.
  ///
  /// `==` and `hashCode` must be value-based (enums, strings, numbers,
  /// records...): the group finds the chosen option by equality.
  final T value;

  /// The text of the option, read by screen readers.
  final String label;

  /// A second line under the label.
  final String? description;

  /// Whether the option can be chosen. A disabled option is shown, skipped by
  /// the keyboard and ignored by taps. A `required` group whose options are all
  /// disabled cannot be satisfied.
  final bool enabled;
}

/// The options of a choice group without duplicates, keeping the first option
/// of each value. In a debug build an empty list or a duplicate value asserts,
/// with [owner] (the widget name) in the message.
List<ChoiceOption<T>> uniqueOptions<T>(
  List<ChoiceOption<T>> options,
  String owner,
) {
  assert(options.isNotEmpty, '$owner.options must not be empty.');
  assert(
    options.map((o) => o.value).toSet().length == options.length,
    '$owner.options must have unique values.',
  );
  final seen = <T>{};
  return [
    for (final option in options)
      if (seen.add(option.value)) option,
  ];
}

/// In a debug build, asserts that [initialValue] is null or the value of one of
/// [options], with [owner] (the widget name) in the message.
void assertInOptions<T>(
  List<ChoiceOption<T>> options,
  T? initialValue,
  String owner,
) {
  assert(
    initialValue == null || options.any((o) => o.value == initialValue),
    '$owner.initialValue must be one of the options.',
  );
}

/// In a debug build, asserts that every value of [initialValue] is the value of
/// an option of [options], with [owner] (the widget name) in the message.
void assertSetInOptions<T>(
  List<ChoiceOption<T>> options,
  Set<T>? initialValue,
  String owner,
) {
  assert(
    (initialValue ?? const {}).every((v) => options.any((o) => o.value == v)),
    '$owner.initialValue must only hold values of the options.',
  );
}

/// The index of the option that receives the field's `focusNode`: the first
/// enabled option of an enabled field, or -1 (the node then stays unattached).
int firstEnabledOption<T>(
  List<ChoiceOption<T>> options, {
  required bool fieldEnabled,
}) => fieldEnabled ? options.indexWhere((o) => o.enabled) : -1;

/// The next value of a multiple-choice group when [toggled] becomes [chosen],
/// in the order of [options]; values that match no option stay at the end.
/// Unmodifiable.
Set<T> nextChosen<T>(
  List<ChoiceOption<T>> options,
  Set<T> current,
  T toggled, {
  required bool chosen,
}) {
  final next = {...current}..remove(toggled);
  if (chosen) next.add(toggled);
  return Set<T>.unmodifiable({
    for (final o in options)
      if (next.contains(o.value)) o.value,
    for (final v in next)
      if (!options.any((o) => o.value == v)) v,
  });
}
