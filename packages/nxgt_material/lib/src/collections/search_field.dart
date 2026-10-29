import 'dart:async';
import 'dart:ui' show SemanticsInputType;

import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// A search input that reports its text once typing pauses.
///
/// Prefer it to a bare Material 3 `TextField` for filtering a list or a
/// table: it adds the search icon, a localized hint, a clear button that
/// shows only when there is text, the `search` keyboard action and a
/// debounce, so the app filters or queries once per pause instead of once
/// per keystroke. It is not a `FormField`; use `TextField` fields for forms.
///
/// [onChanged] fires [debounce] after the last keystroke. Clearing with the
/// button emits `''` at once and keeps the focus in the field. Submitting
/// emits at once through [onSubmitted] and drops a pending [onChanged].
/// [debounce] of [Duration.zero] emits at every keystroke. It only emits
/// text; filtering (for example accent-insensitive) is the app's.
class SearchField extends StatefulWidget {
  /// Creates a search field.
  ///
  /// Give [controller] or [initialValue], not both.
  const new({
    required this.onChanged,
    this.debounce = const Duration(milliseconds: 300),
    this.controller,
    this.initialValue,
    this.hintText,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    this.enabled = true,
    super.key,
  }) : assert(
         controller == null || initialValue == null,
         'SearchField.controller and SearchField.initialValue '
         'must not both be given.',
       ),
       assert(
         debounce >= Duration.zero,
         'SearchField.debounce must not be negative.',
       );

  /// Called with the text once typing pauses for [debounce], and at once when
  /// the clear button is used.
  final ValueChanged<String> onChanged;

  /// How long typing must pause before [onChanged]. Zero emits at every edit.
  final Duration debounce;

  /// Controls the text. The field never disposes it.
  final TextEditingController? controller;

  /// The starting text when no [controller] is given.
  final String? initialValue;

  /// The placeholder, also the accessible label while the field is empty.
  /// Defaults to the localized "Search".
  final String? hintText;

  /// Called at once with the text when the keyboard action is used.
  final ValueChanged<String>? onSubmitted;

  /// Whether to take the focus when first built.
  final bool autofocus;

  /// The focus node. The field never disposes it.
  final FocusNode? focusNode;

  /// Whether input is accepted. A disabled field has no clear button.
  final bool enabled;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController? _owned;
  FocusNode? _ownedFocus;
  Timer? _timer;

  TextEditingController get _controller => widget.controller ?? _owned!;
  FocusNode get _focus => widget.focusNode ?? _ownedFocus!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _owned = TextEditingController(text: widget.initialValue);
    }
    if (widget.focusNode == null) _ownedFocus = FocusNode();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(SearchField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _owned)!.removeListener(_onControllerChanged);
      if (widget.controller == null) {
        _owned = TextEditingController(text: old.controller?.text);
      } else {
        _owned?.dispose();
        _owned = null;
      }
      _controller.addListener(_onControllerChanged);
      _timer?.cancel();
    }
    if (old.focusNode != widget.focusNode) {
      if (widget.focusNode == null) {
        _ownedFocus = FocusNode();
      } else {
        _ownedFocus?.dispose();
        _ownedFocus = null;
      }
    }
    if (old.enabled && !widget.enabled) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onControllerChanged);
    _owned?.dispose();
    _ownedFocus?.dispose();
    super.dispose();
  }

  // Rebuilds only when the clear button has to appear or go.
  bool _hadText = false;
  void _onControllerChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hadText) {
      _hadText = hasText;
      if (mounted) setState(() {});
    }
  }

  void _edited(String text) {
    _timer?.cancel();
    if (widget.debounce == Duration.zero) {
      widget.onChanged(text);
      return;
    }
    _timer = Timer(widget.debounce, () => widget.onChanged(text));
  }

  void _submitted(String text) {
    _timer?.cancel();
    widget.onSubmitted?.call(text);
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    _focus.requestFocus();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.materialL10n;
    _hadText = _controller.text.isNotEmpty;
    final hint = widget.hintText ?? l10n.collectionsSearchHint;
    return Semantics(
      inputType: SemanticsInputType.search,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        onChanged: _edited,
        onSubmitted: _submitted,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const ExcludeSemantics(child: Icon(Icons.search)),
          suffixIcon: _hadText && widget.enabled
              ? IconButton(
                  style: targetStyle,
                  tooltip: l10n.collectionsSearchClear,
                  icon: const Icon(Icons.close),
                  onPressed: _clear,
                )
              : null,
        ),
      ),
    );
  }
}
