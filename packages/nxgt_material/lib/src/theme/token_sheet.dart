import 'package:flutter/material.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';
import 'package:nxgt_material/src/theme/tone_colors.dart';

/// A sheet of the theme's tokens: every tone with its four colours, then the
/// radius scale.
///
/// For a catalogue, a golden or a theme picker's preview. Needs a theme built
/// from a `ThemeSpec`. A development widget: every swatch is labelled for
/// screen readers with its tone name and role (for example `success color`),
/// in English, not localised.
class TokenSheet extends StatelessWidget {
  /// Creates a token sheet.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radii = context.radii;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tones', style: text.titleMedium),
            const SizedBox(height: 8),
            for (final entry in context.tones.all.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _ToneRow(name: entry.key, tone: entry.value),
              ),
            const SizedBox(height: 12),
            Text('Radius', style: text.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final step in radii.steps.entries)
                  _RadiusChip(name: step.key, radius: step.value),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToneRow extends StatelessWidget {
  const new({required this.name, required this.tone});

  final String name;
  final ToneColors tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(name, style: Theme.of(context).textTheme.labelMedium),
        ),
        _Swatch(
          background: tone.color,
          foreground: tone.onColor,
          label: 'on',
          semanticLabel: '$name color',
        ),
        const SizedBox(width: 4),
        _Swatch(
          background: tone.container,
          foreground: tone.onContainer,
          label: 'on container',
          semanticLabel: '$name container',
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const new({
    required this.background,
    required this.foreground,
    required this.label,
    required this.semanticLabel,
  });

  final Color background;
  final Color foreground;
  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        width: 140,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(context.radii.sm),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  const new({required this.name, required this.radius});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 72,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        name,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: scheme.onSecondaryContainer),
      ),
    );
  }
}
