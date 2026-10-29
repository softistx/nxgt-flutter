import 'package:flutter/widgets.dart';

/// Whether the user's text scale, measured on a text of [fontSize], is at most
/// [factor] times its size. Internal: no barrel exports it.
bool textScaleAtMost(
  BuildContext context,
  double factor, {
  double fontSize = 14,
}) => MediaQuery.textScalerOf(context).scale(fontSize) / fontSize <= factor;
