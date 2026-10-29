import 'package:flutter/material.dart';

/// The smallest touch target, in logical pixels, on every platform.
const minTarget = Size.square(48);

/// A button style that keeps a button at 48 dp, padded, at standard density
/// (Material's desktop density would shrink it). Merge it over a theme's
/// style, or pass it as `style`.
const targetStyle = ButtonStyle(
  minimumSize: WidgetStatePropertyAll(minTarget),
  tapTargetSize: MaterialTapTargetSize.padded,
  visualDensity: VisualDensity.standard,
);

/// A button style that only keeps the 48 dp tap target and the standard
/// density, so desktop density cannot shrink a button, without the 48 dp
/// minimum width of [targetStyle] that would widen short labels.
const tapTargetStyle = ButtonStyle(
  tapTargetSize: MaterialTapTargetSize.padded,
  visualDensity: VisualDensity.standard,
);
