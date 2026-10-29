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
  final T value;

  /// The text of the option, read by screen readers.
  final String label;

  /// A second line under the label.
  final String? description;

  /// Whether the option can be chosen. A disabled option is shown, skipped by
  /// the keyboard and ignored by taps.
  final bool enabled;
}
