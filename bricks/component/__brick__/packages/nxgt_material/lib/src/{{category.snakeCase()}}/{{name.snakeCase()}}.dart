import 'package:flutter/material.dart';

/// {{name.sentenceCase()}}.
///
/// Describe what it is for, in one sentence, and when to prefer it to the
/// Material 3 widget it builds on.
class {{name.pascalCase()}} extends StatelessWidget {
  /// Creates a {{name.sentenceCase()}}.
  const new({
    required this.label,
    super.key,
  });

  /// The text shown, also read by screen readers.
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(label, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}
