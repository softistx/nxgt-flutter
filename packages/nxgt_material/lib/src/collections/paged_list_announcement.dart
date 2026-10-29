import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nxgt_material/src/feedback/live_region.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// The "N more loaded" announcement of a `PagedList`, as a 1 dp node placed in
/// a `Stack`.
///
/// The node has the `status` role (and is a live region off the web, see
/// [liveRegionUnderRole]) and stays in the tree, with an empty label while
/// idle; only its label changes. A new [serial] with a [count] above zero
/// announces it, and the label is cleared after two seconds so the next page,
/// even of the same size, is announced again.
class PagedListAnnouncement extends StatefulWidget {
  /// Creates the announcement.
  const new({required this.count, required this.serial, super.key});

  /// How many items the last page added.
  final int count;

  /// Changes with each page that landed.
  final int serial;

  @override
  State<PagedListAnnouncement> createState() => _PagedListAnnouncementState();
}

class _PagedListAnnouncementState extends State<PagedListAnnouncement> {
  Timer? _timer;
  int _shown = 0;

  @override
  void initState() {
    super.initState();
    _show();
  }

  @override
  void didUpdateWidget(PagedListAnnouncement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serial != widget.serial) _show();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show() {
    _timer?.cancel();
    _shown = widget.count;
    if (_shown == 0) return;
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _shown = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: 1,
      height: 1,
      // The role and the live region sit on two nodes: Flutter refuses both
      // on one.
      child: Semantics(
        container: true,
        role: SemanticsRole.status,
        child: Semantics(
          container: true,
          liveRegion: liveRegionUnderRole,
          label: _shown > 0
              ? context.materialL10n.collectionsLoadedMore(_shown)
              : '',
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
