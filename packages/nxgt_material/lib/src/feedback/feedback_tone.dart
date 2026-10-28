import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations.dart';
import 'package:nxgt_material/src/theme/tone_colors.dart';
import 'package:nxgt_material/src/theme/tones.dart';

/// The meaning of an `InlineAlert` or a toast.
///
/// Each tone has its own icon and a spoken label, so the meaning never rests on
/// colour alone, and its colours come from the theme's `Tones`.
enum FeedbackTone {
  /// Neutral information.
  info(Icons.info_outline, SemanticsRole.status),

  /// Something worked: saved, sent, paid.
  success(Icons.check_circle_outline, SemanticsRole.status),

  /// Needs attention, not yet wrong.
  warning(Icons.warning_amber_rounded, SemanticsRole.alert),

  /// Something failed.
  error(Icons.error_outline, SemanticsRole.alert);

  new(this.icon, this.role);

  /// The icon drawn before the message.
  final IconData icon;

  /// The semantics role: `alert` (assertive) for [warning] and [error],
  /// `status` (polite) for the others.
  final SemanticsRole role;

  /// The colours of this tone in [tones].
  ToneColors colors(Tones tones) => switch (this) {
    FeedbackTone.info => tones.info,
    FeedbackTone.success => tones.success,
    FeedbackTone.warning => tones.warning,
    FeedbackTone.error => tones.error,
  };

  /// The localized word a screen reader says before the message.
  String label(NxgtMaterialLocalizations l10n) => switch (this) {
    FeedbackTone.info => l10n.feedbackToneInfo,
    FeedbackTone.success => l10n.feedbackToneSuccess,
    FeedbackTone.warning => l10n.feedbackToneWarning,
    FeedbackTone.error => l10n.feedbackToneError,
  };
}
