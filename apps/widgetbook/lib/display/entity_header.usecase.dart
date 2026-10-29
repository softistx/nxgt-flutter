import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: EntityHeader, path: '[Display]')
/// The default use-case of [EntityHeader].
Widget buildEntityHeaderDefault(BuildContext context) {
  final name = context.knobs.string(
    label: 'Title',
    initialValue: 'Ada Lovelace',
  );
  return Padding(
    padding: const EdgeInsets.all(16),
    child: EntityHeader(
      title: name,
      subtitle: context.knobs.string(
        label: 'Subtitle',
        initialValue: 'ada@example.com',
      ),
      leading: UserAvatar(name: name, size: 56),
      status: const StatusIndicator(
        label: 'Active',
        tone: FeedbackTone.success,
      ),
      actions: [
        EntityAction(label: 'Edit', icon: Icons.edit, onPressed: () {}),
        EntityAction(
          label: 'Delete',
          icon: Icons.delete_outline,
          destructive: true,
          onPressed: () {},
        ),
      ],
    ),
  );
}
