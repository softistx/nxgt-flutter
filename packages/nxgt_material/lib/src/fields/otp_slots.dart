import 'package:flutter/material.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// The gap between two slots of an `OtpField`, in logical pixels.
const otpSlotGap = 8.0;

/// The width of a row of [length] slots, each 48 dp wide.
double otpSlotsWidth(int length) =>
    length * minTarget.width + (length - 1) * otpSlotGap;

/// The slots an `OtpField` draws under its invisible input: one 48 dp box
/// per digit, the next one to fill highlighted while focused.
///
/// Internal and purely visual: the input above it takes every touch and
/// the screen reader reads the field, so the slots are not in the semantics.
class OtpSlots extends StatelessWidget {
  /// Creates the slots.
  const new({
    required this.text,
    required this.length,
    required this.focused,
    required this.hasError,
    required this.enabled,
    super.key,
  });

  /// The digits typed so far.
  final String text;

  /// How many slots to draw.
  final int length;

  /// Whether the input has focus.
  final bool focused;

  /// Whether the field shows an error.
  final bool hasError;

  /// Whether the field accepts input.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final digitStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: enabled
          ? scheme.onSurface
          : scheme.onSurface.withValues(alpha: .38),
    );
    final active = focused && enabled ? text.length.clamp(0, length - 1) : -1;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: otpSlotGap,
        children: [
          for (var i = 0; i < length; i++)
            Container(
              key: ValueKey('otp-slot-$i'),
              width: minTarget.width,
              height: minTarget.height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: enabled ? null : scheme.onSurface.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: i == active || hasError ? 2 : 1,
                  color: hasError
                      ? scheme.error
                      : i == active
                      ? scheme.primary
                      : scheme.outline.withValues(alpha: enabled ? 1 : .38),
                ),
              ),
              child: i < text.length ? Text(text[i], style: digitStyle) : null,
            ),
        ],
      ),
    );
  }
}
