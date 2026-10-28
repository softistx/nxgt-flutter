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
import 'package:nxgt_widgetbook/fields/email_field.usecase.dart'
    as _nxgt_widgetbook_fields_email_field_usecase;
import 'package:nxgt_widgetbook/fields/number_field.usecase.dart'
    as _nxgt_widgetbook_fields_number_field_usecase;
import 'package:nxgt_widgetbook/fields/password_field.usecase.dart'
    as _nxgt_widgetbook_fields_password_field_usecase;
import 'package:nxgt_widgetbook/fields/phone_field.usecase.dart'
    as _nxgt_widgetbook_fields_phone_field_usecase;
import 'package:nxgt_widgetbook/fields/text_area_field.usecase.dart'
    as _nxgt_widgetbook_fields_text_area_field_usecase;
import 'package:nxgt_widgetbook/forms/form_section.usecase.dart'
    as _nxgt_widgetbook_forms_form_section_usecase;
import 'package:nxgt_widgetbook/forms/submit_button.usecase.dart'
    as _nxgt_widgetbook_forms_submit_button_usecase;
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
    name: 'Fields',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'EmailField',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_fields_email_field_usecase
                .buildEmailFieldDefault,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'NumberField',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_fields_number_field_usecase
                .buildNumberFieldDefault,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'PasswordField',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_fields_password_field_usecase
                .buildPasswordFieldDefault,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'PhoneField',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_fields_phone_field_usecase
                .buildPhoneFieldDefault,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'TextAreaField',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_fields_text_area_field_usecase
                .buildTextAreaFieldDefault,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Forms',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'FormSection',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_forms_form_section_usecase
                .buildFormSectionDefault,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SubmitButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _nxgt_widgetbook_forms_submit_button_usecase
                .buildSubmitButtonDefault,
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
