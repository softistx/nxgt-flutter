import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/layout/window_size.dart';
import 'package:nxgt_material/src/overlays/adaptive_sheet.dart';
import 'package:nxgt_material/src/selection/choice_field_base.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
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

  String _labelOf(T? value) {
    if (value == null) return '';
    for (final option in widget.options) {
      if (option.value == value) return option.label;
    }
    return '';
  }

  List<DropdownMenuEntry<T>> _buildEntries(BuildContext context) => [
    for (final option in widget.options)
      DropdownMenuEntry<T>(
        value: option.value,
        label: option.label,
        enabled: option.enabled,
        style: targetStyle,
        labelWidget: option.description == null
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(option.label),
                  Text(
                    option.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
      ),
  ];

  @override
  void didUpdateWidget(_SelectControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final optionsChanged = !identical(oldWidget.options, widget.options);
    if (optionsChanged) _entries = null;
    if (oldWidget.value != widget.value || optionsChanged) {
      _controller.text = _labelOf(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSheet() async {
    if (!widget.enabled) return;
    final searchLabel = context.materialL10n.fieldsSelectSearch;
    final picked = await context.showAdaptiveSheet<(T,)>(
      title: widget.label,
      builder: (_) => _SheetList<T>(
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

  InputDecorationThemeData? _errorTheme(BuildContext context) {
    if (!widget.hasError) return null;
    final color = Theme.of(context).colorScheme.error;
    OutlineInputBorder border(double width) => OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
    );
    return InputDecorationThemeData(
      border: border(1),
      enabledBorder: border(1),
      focusedBorder: border(2),
      floatingLabelStyle: TextStyle(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorTheme = _errorTheme(context);
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
          focusNode: widget.focusNode,
          requestFocusOnTap: widget.searchable ? true : null,
          enableFilter: widget.searchable,
          enableSearch: widget.searchable,
          trailingIcon: _trailing(open: false),
          selectedTrailingIcon: _trailing(open: true),
          inputDecorationTheme: errorTheme,
          dropdownMenuEntries: _entries ??= _buildEntries(context),
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

/// The content of the sheet: a search box above the options as 48 dp tiles.
class _SheetList<T> extends StatefulWidget {
  const new({
    required this.options,
    required this.selected,
    required this.searchLabel,
  });

  final List<ChoiceOption<T>> options;
  final T? selected;
  final String searchLabel;

  @override
  State<_SheetList<T>> createState() => _SheetListState<T>();
}

class _SheetListState<T> extends State<_SheetList<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final needle = _fold(_query.trim());
    final shown = [
      for (final option in widget.options)
        if (needle.isEmpty || _fold(option.label).contains(needle)) option,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: widget.searchLabel,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        for (final option in shown)
          ListTile(
            minTileHeight: minTarget.height,
            contentPadding: EdgeInsets.zero,
            enabled: option.enabled,
            selected: option.value == widget.selected,
            title: Text(option.label),
            subtitle: option.description == null
                ? null
                : Text(option.description!),
            trailing: option.value == widget.selected
                ? const Icon(Icons.check)
                : null,
            onTap: option.enabled
                ? () => Navigator.of(context).pop<(T,)>((option.value,))
                : null,
          ),
      ],
    );
  }
}

const _from = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
const _to = 'aaaaaaceeeeiiiinooooouuuuyy';

/// Lower case without the common Latin accents, to compare labels.
String _fold(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final i = _from.indexOf(char);
    buffer.write(i == -1 ? char : _to[i]);
  }
  return buffer.toString();
}
