import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/theme/theme_context.dart';

/// Whether the person an avatar stands for is available.
///
/// Each value has a localized spoken name, so the status never rests on the
/// dot's colour alone.
enum AvatarPresence {
  /// Available now.
  online,

  /// Signed in but away.
  away,

  /// Do not disturb.
  busy,

  /// Not signed in.
  offline;

  /// The localized word a screen reader says after the name.
  String label(NxgtMaterialLocalizations l10n) => switch (this) {
    AvatarPresence.online => l10n.displayPresenceOnline,
    AvatarPresence.away => l10n.displayPresenceAway,
    AvatarPresence.busy => l10n.displayPresenceBusy,
    AvatarPresence.offline => l10n.displayPresenceOffline,
  };
}

/// A person's avatar: their picture, or their initials on a colour that the
/// name always gives the same.
///
/// Built on `CircleAvatar`. The initials (first letters of the first and last
/// words of [name]) are shown when there is no [image], while it loads and if
/// it fails. The fill is one of the theme's tones picked from [name], with
/// AA text contrast. An empty [name] draws a generic person icon. [presence]
/// adds a dot on the corner. A screen reader says the name, then the localized
/// presence; the image itself is excluded.
class UserAvatar extends StatelessWidget {
  /// Creates a UserAvatar.
  const new({
    required this.name,
    this.image,
    this.size = 40,
    this.presence,
    super.key,
  }) : assert(size > 0, 'UserAvatar.size must be positive.');

  /// The person's name; gives the initials, the tone and the spoken label.
  final String name;

  /// The picture. The initials show instead while it loads or if it fails.
  final ImageProvider? image;

  /// The diameter in logical pixels.
  final double size;

  /// The dot on the corner, or none.
  final AvatarPresence? presence;

  @override
  Widget build(BuildContext context) {
    // Release builds degrade: a size of 0 or less draws the default 40.
    final diameter = size > 0 ? size : 40.0;
    final tones = context.tones;
    final palette = [
      tones.primary,
      tones.secondary,
      tones.tertiary,
      tones.success,
      tones.info,
      tones.warning,
    ];
    final trimmed = name.trim();
    final colors = trimmed.isEmpty
        ? tones.neutral
        : palette[_stableHash(
                trimmed.split(RegExp(r'\s+')).join(' ').toLowerCase(),
              ) %
              palette.length];
    final initials = _initials(trimmed);

    Widget fallback() => initials.isEmpty
        ? Icon(Icons.person, size: diameter * 0.6, color: colors.onContainer)
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              initials,
              maxLines: 1,
              textScaler: TextScaler.noScaling,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.onContainer,
                fontSize: diameter * 0.4,
                height: 1,
              ),
            ),
          );

    final picture = image;
    final avatar = CircleAvatar(
      radius: diameter / 2,
      backgroundColor: colors.container,
      child: picture == null
          ? fallback()
          : ClipOval(
              child: Image(
                image: picture,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                frameBuilder: (context, child, frame, sync) =>
                    frame == null && !sync ? Center(child: fallback()) : child,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: fallback()),
              ),
            ),
    );

    final status = presence;
    final label = [
      if (trimmed.isNotEmpty) trimmed,
      if (status != null) status.label(context.materialL10n),
    ].join(', ');
    return Semantics(
      container: true,
      image: true,
      label: label.isEmpty ? null : label,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: diameter,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: avatar),
            if (status != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: _PresenceDot(
                  presence: status,
                  diameter: (diameter * 0.3).clamp(8, 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// FNV-1a over the code units: the same on every platform and run, unlike
  /// `String.hashCode`.
  static int _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  static String _initials(String name) {
    final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '';
    String first(String word) => String.fromCharCode(word.runes.first);
    final letters = words.length == 1
        ? first(words.first)
        : first(words.first) + first(words.last);
    return letters.toUpperCase();
  }
}

class _PresenceDot extends StatelessWidget {
  const new({required this.presence, required this.diameter});

  final AvatarPresence presence;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final color = switch (presence) {
      AvatarPresence.online => tones.success.color,
      AvatarPresence.away => tones.warning.color,
      AvatarPresence.busy => tones.error.color,
      AvatarPresence.offline => tones.neutral.color,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: SizedBox.square(dimension: diameter),
    );
  }
}
