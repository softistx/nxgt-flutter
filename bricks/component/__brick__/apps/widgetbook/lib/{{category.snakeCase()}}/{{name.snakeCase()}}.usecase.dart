import 'package:flutter/material.dart';
import 'package:nxgt_material/{{category.snakeCase()}}.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: {{name.pascalCase()}},
  path: '[{{category.pascalCase()}}]',
)
/// The default use-case of [{{name.pascalCase()}}].
Widget build{{name.pascalCase()}}Default(BuildContext context) {
  return {{name.pascalCase()}}(
    label: context.knobs.string(label: 'Label', initialValue: 'Hello'),
  );
}
