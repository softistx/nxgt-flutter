import 'package:flutter/foundation.dart';

/// Whether a node that already has the `alert` or `status` role is also
/// marked as a live region.
///
/// On the web the role alone is announced (the browser treats `role="alert"`
/// and `role="status"` as live regions), and a Flutter live region adds a
/// second announcement of the same text. Elsewhere the role is not announced,
/// so the live region is what speaks.
const bool liveRegionUnderRole = !kIsWeb;
