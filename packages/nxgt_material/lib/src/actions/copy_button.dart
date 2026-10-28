import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';

/// An icon button that copies [value] to the clipboard and shows a check
/// mark for a moment.
///
/// Prefer it to a bare [IconButton] for an identifier, a code or a link the
/// user will paste elsewhere. The tooltip reads "Copy", then "Copied", and the
/// change is announced to screen readers.
class CopyButton extends StatefulWidget {
  /// Creates a CopyButton.
  const new({
    required this.value,
    this.onCopied,
    this.resetAfter = const Duration(seconds: 2),
    this.tooltip,
    super.key,
  });

  /// The text put on the clipboard.
  final String value;

  /// Called once the text is on the clipboard.
  final VoidCallback? onCopied;

  /// How long the check mark stays before the copy icon comes back.
  final Duration resetAfter;

  /// Overrides the localized "Copy" tooltip and label.
  final String? tooltip;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  Timer? _timer;
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    widget.onCopied?.call();
    setState(() => _copied = true);
    _timer?.cancel();
    _timer = Timer(widget.resetAfter, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.materialL10n;
    final message = _copied
        ? l10n.actionsCopied
        : widget.tooltip ?? l10n.actionsCopy;
    return MergeSemantics(
      child: Semantics(
        liveRegion: true,
        label: message,
        child: Tooltip(
          message: message,
          excludeFromSemantics: true,
          child: IconButton(
            onPressed: _copy,
            icon: Icon(_copied ? Icons.check : Icons.content_copy_outlined),
          ),
        ),
      ),
    );
  }
}
