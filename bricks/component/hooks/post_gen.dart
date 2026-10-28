import 'package:mason/mason.dart';

String _snake(String pascal) => pascal
    .replaceAllMapped(
      RegExp('(?<=[a-z0-9])[A-Z]'),
      (m) => '_${m.group(0)}',
    )
    .toLowerCase();

void run(HookContext context) {
  final category = context.vars['category'] as String;
  final snake = _snake(context.vars['name'] as String);
  context.logger
    ..info('')
    ..info('Two steps are left to you:')
    ..info(
      '  1. packages/nxgt_material/lib/$category.dart: '
      "export 'src/$category/$snake.dart'; (a category's library is created "
      'with its first component, and exported from nxgt_material.dart)',
    )
    ..info(
      '  2. melos run gen (Widgetbook directories), then '
      'melos run goldens:update on Linux.',
    )
    ..info('Then add a line to packages/nxgt_material/CHANGELOG.md.');
}
