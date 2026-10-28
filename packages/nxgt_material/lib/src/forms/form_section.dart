import 'package:flutter/material.dart';

/// A titled group of related form fields.
///
/// Lays [children] out in a column with even spacing under a [title] that a
/// screen reader announces as a heading, so a long form can be navigated by
/// section. Use one per topic ("Account", "Address") inside a `Form`.
class FormSection extends StatelessWidget {
  /// Creates a FormSection.
  const new({
    required this.title,
    required this.children,
    this.description,
    this.spacing = 16,
    super.key,
  });

  /// The heading of the section.
  final String title;

  /// A sentence under the heading that explains what the section is for.
  final String? description;

  /// The fields, laid out in a column.
  final List<Widget> children;

  /// The vertical gap between the heading, the description and each child.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = this.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            if (description != null)
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        ...children,
      ],
    );
  }
}
