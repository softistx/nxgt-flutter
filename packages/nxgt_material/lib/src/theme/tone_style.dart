import 'package:flutter/material.dart';

/// The colour while enabled; `null` when disabled, so the theme's disabled
/// look applies. Internal: no barrel exports it.
WidgetStateProperty<Color?> whenEnabled(Color color) =>
    WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled) ? null : color,
    );
