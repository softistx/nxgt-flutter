import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nxgt_material/src/feedback/live_region.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/selection/choice_option.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// The content of the sheet: a search box above the options as 48 dp tiles.
class SelectSheetList<T> extends StatefulWidget {
  /// Creates the content of the sheet.
  const new({
    required this.options,
    required this.selected,
    required this.searchLabel,
    super.key,
  });

  /// The options, in display order.
  final List<ChoiceOption<T>> options;

  /// The chosen value, marked in the list.
  final T? selected;

  /// The label of the search box.
  final String searchLabel;

  @override
  State<SelectSheetList<T>> createState() => _SelectSheetListState<T>();
}

class _SelectSheetListState<T> extends State<SelectSheetList<T>> {
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
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            // The role and the live region sit on two nodes: Flutter refuses
            // both on one.
            child: Semantics(
              container: true,
              role: SemanticsRole.status,
              child: Semantics(
                container: true,
                liveRegion: liveRegionUnderRole,
                child: Text(
                  context.materialL10n.fieldsSelectNoResults,
                  textAlign: TextAlign.center,
                ),
              ),
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
