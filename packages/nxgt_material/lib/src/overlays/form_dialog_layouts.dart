import 'package:flutter/material.dart';
import 'package:nxgt_material/src/l10n/localizations_context.dart';
import 'package:nxgt_material/src/theme/targets.dart';

/// The widest the dialog grows, in logical pixels, from the medium size up.
const _dialogWidth = 560.0;

/// Escape, locked while busy. A page route has no dismissible barrier to
/// take the key, so on the full-screen layout the dialog takes it itself;
/// the `Scaffold` has its own `Actions` for `DismissIntent`, so there it
/// wraps the app bar and the body, not the `Scaffold`.
Widget formDialogGuard({
  required bool busy,
  required bool fullscreen,
  required VoidCallback close,
  required Widget child,
}) {
  final actions = <Type, Action<Intent>>{
    if (busy)
      DismissIntent: DoNothingAction()
    else if (fullscreen)
      DismissIntent: CallbackAction<DismissIntent>(
        onInvoke: (_) {
          close();
          return null;
        },
      ),
  };
  return Actions(actions: actions, child: child);
}

/// The full-screen layout: an app bar with the close button, the title and
/// [submit], over the scrolling [child].
Widget formDialogFullscreen({
  required BuildContext context,
  required ThemeData theme,
  required String title,
  required Widget child,
  required Widget submit,
  required bool busy,
  required VoidCallback close,
  required FocusNode focus,
}) {
  final l10n = context.materialL10n;
  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: formDialogGuard(
        busy: busy,
        fullscreen: true,
        close: close,
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: withTargets(
            theme,
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.actionsClose,
              onPressed: busy ? null : close,
              style: targetStyle,
            ),
          ),
          title: Semantics(
            header: true,
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: submit,
            ),
          ],
        ),
      ),
    ),
    body: formDialogGuard(
      busy: busy,
      fullscreen: true,
      close: close,
      child: Focus(
        focusNode: focus,
        skipTraversal: true,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 24),
            child: child,
          ),
        ),
      ),
    ),
  );
}

/// The dialog layout: [child] with Cancel and [submit] at the bottom.
Widget formDialogDialog({
  required BuildContext context,
  required String title,
  required Widget child,
  required Widget submit,
  required bool busy,
  required VoidCallback close,
}) {
  return AlertDialog(
    title: Semantics(header: true, child: Text(title)),
    content: SizedBox(width: _dialogWidth, child: child),
    scrollable: true,
    semanticLabel: title,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: _dialogWidth),
    actions: [
      TextButton(
        onPressed: busy ? null : close,
        style: targetStyle,
        child: Text(context.materialL10n.actionsCancel),
      ),
      submit,
    ],
  );
}

/// [child] with the buttons below it kept at 48 dp on every platform.
Widget withTargets(ThemeData theme, Widget child) {
  ButtonStyle merged(ButtonStyle? base) =>
      base?.merge(targetStyle) ?? targetStyle;
  return Theme(
    data: theme.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: merged(theme.filledButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: merged(theme.textButtonTheme.style),
      ),
    ),
    child: child,
  );
}
