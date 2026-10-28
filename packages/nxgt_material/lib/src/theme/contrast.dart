import 'dart:ui';

/// The WCAG 2.x contrast ratio between [a] and [b], 1 to 21.
double wcagContrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
