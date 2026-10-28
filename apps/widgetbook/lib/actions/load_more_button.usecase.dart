import 'package:flutter/material.dart';
import 'package:nxgt_material/actions.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: LoadMoreButton, path: '[Actions]')
/// The default use-case of [LoadMoreButton].
Widget buildLoadMoreButtonDefault(BuildContext context) {
  return LoadMoreButton(
    hasMore: context.knobs.boolean(label: 'Has more', initialValue: true),
    onPressed: () => Future<void>.delayed(const Duration(seconds: 1)),
  );
}
