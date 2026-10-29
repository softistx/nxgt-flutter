import 'package:flutter/material.dart';
import 'package:nxgt_material/collections.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: PagedList, path: '[Collections]')
/// The default use-case of [PagedList]: ten items per page, three pages.
Widget buildPagedListDefault(BuildContext context) {
  return _PagedListDemo(
    mode: context.knobs.object.dropdown(
      label: 'Load more mode',
      options: LoadMoreMode.values,
      initialOption: LoadMoreMode.button,
      labelBuilder: (mode) => mode.name,
    ),
    failFirstLoad: context.knobs.boolean(label: 'First load fails'),
  );
}

class _PagedListDemo extends StatefulWidget {
  const new({required this.mode, required this.failFirstLoad});

  final LoadMoreMode mode;
  final bool failFirstLoad;

  @override
  State<_PagedListDemo> createState() => _PagedListDemoState();
}

class _PagedListDemoState extends State<_PagedListDemo> {
  static const _pages = 3;
  static const _pageSize = 10;
  List<String> _items = [for (var i = 0; i < _pageSize; i++) 'Item $i'];

  Future<void> _loadMore() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _items = [
        ..._items,
        for (var i = _items.length; i < _items.length + _pageSize; i++)
          'Item $i',
      ];
    });
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _items = [for (var i = 0; i < _pageSize; i++) 'Item $i'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.failFirstLoad) {
      return PagedList<String>(
        items: const [],
        itemBuilder: (context, item, index) => ListTile(title: Text(item)),
        error: 'offline',
        onRetry: () async {},
      );
    }
    return PagedList<String>(
      items: _items,
      hasMore: _items.length < _pages * _pageSize,
      loadMoreMode: widget.mode,
      onLoadMore: _loadMore,
      onRefresh: _refresh,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, item, index) => ListTile(title: Text(item)),
    );
  }
}
