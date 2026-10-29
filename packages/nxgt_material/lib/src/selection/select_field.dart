import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/layout/window_size.dart';
import 'package:nxgt_material/src/overlays/adaptive_sheet.dart';
import 'package:nxgt_material/src/selection/choice_field_base.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
import 'package:nxgt_material/src/selection/select_menu.dart';
import 'package:nxgt_material/src/selection/select_sheet.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// More options than this open a searchable sheet on a compact window.
const _sheetThreshold = 12;

/// A single choice in a list, as a form field that looks like a text field.
///
/// On Material 3 `DropdownMenu` (which is not a form field) for a few
/// options or from the medium window size up. On a compact window, with
/// [searchable] or more than 12 options, a tap opens a sheet
/// (`context.showAdaptiveSheet`) with a search box and a list of 48 dp tiles.
/// With `required` it is valid only once an option is chosen; without it a
/// clear button returns the value to `null`. Works in a [Form] (validate,
/// save, reset). For two to six options that should stay visible use
/// `RadioGroupField`.
///
/// The value is `T?`: `null` means nothing chosen.
class SelectField<T> extends ChoiceFieldBase<T?> {
  /// Creates a SelectField.
  const new({
    required super.label,
    required this.options,
    super.initialValue,
    super.focusNode,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.required,
    super.helperText,
    this.searchable = false,
    super.key,
  });

  /// The options, in display order. Values must be unique.
  final List<ChoiceOption<T>> options;

  /// Whether the user can type to filter the options.
  final bool searchable;

  @override
  Widget build(BuildContext context) {
    assert(
      initialValue == null || options.any((o) => o.value == initialValue),
      'SelectField.initialValue must be one of the options.',
    );
    final unique = uniqueOptions(options, 'SelectField');
    final sheet =
        context.windowSize == WindowSize.compact &&
        (searchable || unique.length > _sheetThreshold);
    return buildChoice(
      context,
      builder: (context, state) => _SelectControl<T>(
        label: label,
        options: unique,
        value: state.value,
        enabled: enabled,
        required: this.required,
        searchable: searchable,
        sheet: sheet,
        focusNode: focusNode,
        hasError: enabled && state.hasError,
        onPick: (value) => change(state, value),
      ),
    );
  }
}

class _SelectControl<T> extends StatefulWidget {
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
  });

  final String label;
  final List<ChoiceOption<T>> options;
  final T? value;
  final bool enabled;
  final bool required;
  final bool searchable;
  final bool sheet;
  final FocusNode? focusNode;
  final bool hasError;
  final ValueChanged<T?> onPick;

  @override
  State<_SelectControl<T>> createState() => _SelectControlState<T>();
}

class _SelectControlState<T> extends State<_SelectControl<T>> {
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
  void didUpdateWidget(_SelectControl<T> oldWidget) {
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
    final searchLabel = context.materialL10n.fieldsSelectSearch;
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

  Widget _trailing({required bool open}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_canClear)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: context.materialL10n.fieldsSelectClear,
            onPressed: () => widget.onPick(null),
            style: targetStyle,
          ),
        Icon(open ? Icons.arrow_drop_up : Icons.arrow_drop_down),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorTheme = widget.hasError ? selectErrorTheme(context) : null;
    final Widget field;
    if (widget.sheet) {
      final theme = Theme.of(context);
      field = CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter): _openSheet,
          const SingleActivator(LogicalKeyboardKey.space): _openSheet,
          const SingleActivator(LogicalKeyboardKey.arrowDown): _openSheet,
        },
        child: Theme(
          data: errorTheme == null
              ? theme
              : theme.copyWith(inputDecorationTheme: errorTheme),
          // One button that opens the sheet; the clear action stays a custom
          // action of the field (see below).
          child: Semantics(
            button: true,
            enabled: widget.enabled,
            label: widget.label,
            value: _controller.text,
            onTap: widget.enabled ? _openSheet : null,
            child: ExcludeSemantics(
              child: TextField(
                controller: _controller,
                readOnly: true,
                enabled: widget.enabled,
                focusNode: widget.focusNode,
                onTap: _openSheet,
                mouseCursor: widget.enabled ? SystemMouseCursors.click : null,
                decoration: InputDecoration(
                  labelText: widget.label,
                  suffixIcon: _trailing(open: false),
                ),
              ),
            ),
          ),
        ),
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
            label: context.materialL10n.fieldsSelectClear,
          ): () =>
              widget.onPick(null),
      },
      child: field,
    );
  }
}
