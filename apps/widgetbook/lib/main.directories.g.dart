// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:nxgt_widgetbook/actions/async_button.usecase.dart'
    as _nxgt_widgetbook_actions_async_button_usecase;
import 'package:nxgt_widgetbook/actions/copy_button.usecase.dart'
    as _nxgt_widgetbook_actions_copy_button_usecase;
import 'package:nxgt_widgetbook/actions/load_more_button.usecase.dart'
    as _nxgt_widgetbook_actions_load_more_button_usecase;
import 'package:nxgt_widgetbook/actions/split_button.usecase.dart'
    as _nxgt_widgetbook_actions_split_button_usecase;
import 'package:nxgt_widgetbook/theme/token_sheet.usecase.dart'
    as _nxgt_widgetbook_theme_token_sheet_usecase;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Actions',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'AsyncButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_actions_async_button_usecase
                .buildAsyncButtonDefault,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CopyButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_actions_copy_button_usecase
                .buildCopyButtonDefault,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'LoadMoreButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_actions_load_more_button_usecase
                .buildLoadMoreButtonDefault,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SplitButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_actions_split_button_usecase
                .buildSplitButtonDefault,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Theme',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'TokenSheet',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_theme_token_sheet_usecase
                .buildTokenSheetDefault,
          ),
        ],
      ),
    ],
  ),
];
