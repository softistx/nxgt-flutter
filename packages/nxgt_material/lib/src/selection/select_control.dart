import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/overlays/adaptive_sheet.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
import 'package:nxgt_material/src/selection/select_menu.dart';
import 'package:nxgt_material/src/selection/select_sheet.dart';
import 'package:nxgt_material/src/selection/select_sheet_field.dart';

/// The menu or sheet control of a `SelectField`. Internal, not exported.
class SelectControl<T> extends StatefulWidget {
  /// Creates the control.
  const new({
    required this.label,
    required this.options,
    required this.value,
    required this.enabled,
    required this.required,
    required this.searchable,
    required this.sheet,
    required this.focusNode,
    required this.hasError,
    required this.onPick,
    super.key,
  });

  /// The visible label.
  final String label;

  /// The unique options, in display order.
  final List<ChoiceOption<T>> options;

  /// The chosen value, `null` for none.
  final T? value;

  /// Whether the control reacts.
  final bool enabled;

  /// Whether a value is required (no clear button).
  final bool required;

  /// Whether the user can type to filter.
  final bool searchable;

  /// Whether a tap opens a sheet instead of a menu.
  final bool sheet;

  /// The caller's focus node, if any.
  final FocusNode? focusNode;

  /// Whether to draw the error state.
  final bool hasError;

  /// Called with the picked value, `null` when cleared.
  final ValueChanged<T?> onPick;

  @override
  State<SelectControl<T>> createState() => _SelectControlState<T>();
}

class _SelectControlState<T> extends State<SelectControl<T>> {
  late final TextEditingController _controller = TextEditingController(
    text: _labelOf(widget.value),
  );
  final MenuController _menu = MenuController();
  List<DropdownMenuEntry<T>>? _entries;
  ThemeData? _entriesTheme;
  FocusNode? _ownNode;
  FocusNode? _watched;

  /// The node whose loss of focus puts the typed text back: the caller's, or
  /// our own for a searchable menu.
  FocusNode? get _node =>
      widget.focusNode ??
      (widget.searchable && !widget.sheet ? (_ownNode ??= FocusNode()) : null);

  void _watch() {
    final node = _node;
    if (identical(node, _watched)) return;
    _watched?.removeListener(_onFocus);
    _watched = node?..addListener(_onFocus);
  }

  /// Without a choice, text typed to search does not stay in the field.
  void _onFocus() {
    if (!(_watched?.hasFocus ?? true)) {
      _controller.text = _labelOf(widget.value);
    }
  }

  @override
  void initState() {
    super.initState();
    _watch();
  }

  String _labelOf(T? value) {
    if (value == null) return '';
    for (final option in widget.options) {
      if (option.value == value) return option.label;
    }
    return '';
  }

  @override
  void didUpdateWidget(SelectControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final optionsChanged = !identical(oldWidget.options, widget.options);
    if (optionsChanged) _entries = null;
    _watch();
    if (oldWidget.value != widget.value || optionsChanged) {
      _controller.text = _labelOf(widget.value);
    }
  }

  @override
  void dispose() {
    _watched?.removeListener(_onFocus);
    _ownNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSheet() async {
    if (!widget.enabled) return;
    final searchLabel = context.materialL10n.collectionsSearchHint;
    final picked = await context.showAdaptiveSheet<(T,)>(
      title: widget.label,
      builder: (_) => SelectSheetList<T>(
        options: widget.options,
        selected: widget.value,
        searchLabel: searchLabel,
      ),
    );
    if (picked != null && mounted) widget.onPick(picked.$1);
  }

  /// Opens the closed menu with Space, which Flutter's `DropdownMenu` leaves
  /// unbound (it handles Enter and, once open, the arrows). While typing
  /// filters the options, Space stays a character.
  KeyEventResult _onMenuKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !widget.enabled || _menu.isOpen) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (widget.searchable || key != LogicalKeyboardKey.space) {
      return KeyEventResult.ignored;
    }
    _menu.open();
    return KeyEventResult.handled;
  }

  List<DropdownMenuEntry<T>> _entriesFor(ThemeData theme) {
    if (_entries == null || !identical(_entriesTheme, theme)) {
      _entriesTheme = theme;
      _entries = selectEntries(widget.options, theme);
    }
    return _entries!;
  }

  bool get _canClear =>
      widget.enabled && !widget.required && widget.value != null;

  Widget _trailing({required bool open}) => selectTrailing(
    context,
    open: open,
    canClear: _canClear,
    onClear: () => widget.onPick(null),
  );

  @override
  Widget build(BuildContext context) {
    final errorTheme = widget.hasError ? selectErrorTheme(context) : null;
    final Widget field;
    if (widget.sheet) {
      field = SelectSheetField(
        label: widget.label,
        controller: _controller,
        enabled: widget.enabled,
        focusNode: widget.focusNode,
        errorTheme: errorTheme,
        trailing: _trailing(open: false),
        onOpen: _openSheet,
      );
    } else {
      field = Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onMenuKey,
        child: DropdownMenu<T>(
          menuController: _menu,
          selectOnly: !widget.searchable,
          controller: _controller,
          initialSelection: widget.value,
          enabled: widget.enabled,
          label: Text(widget.label),
          expandedInsets: EdgeInsets.zero,
          focusNode: _node,
          requestFocusOnTap: widget.searchable ? true : null,
          enableFilter: widget.searchable,
          enableSearch: widget.searchable,
          trailingIcon: _trailing(open: false),
          selectedTrailingIcon: _trailing(open: true),
          inputDecorationTheme: errorTheme,
          dropdownMenuEntries: _entriesFor(Theme.of(context)),
          onSelected: (value) {
            if (value != null && widget.enabled) widget.onPick(value);
          },
        ),
      );
    }
    return Semantics(
      customSemanticsActions: {
        if (_canClear)
          CustomSemanticsAction(
            label: context.materialL10n.selectionClear,
          ): () =>
              widget.onPick(null),
      },
      child: field,
    );
  }
}
