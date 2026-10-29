import 'package:flutter/material.dart';
import 'package:nxgt_material/display.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: UserAvatar, path: '[Display]')
/// The default use-case of [UserAvatar].
Widget buildUserAvatarDefault(BuildContext context) {
  return Center(
    child: UserAvatar(
      name: context.knobs.string(label: 'Name', initialValue: 'Ada Lovelace'),
      size: context.knobs.double.slider(
        label: 'Size',
        initialValue: 56,
        min: 24,
        max: 128,
      ),
      presence: context.knobs.objectOrNull.dropdown<AvatarPresence>(
        label: 'Presence',
        initialOption: AvatarPresence.online,
        options: AvatarPresence.values,
        labelBuilder: (value) => value.name,
      ),
    ),
  );
}
