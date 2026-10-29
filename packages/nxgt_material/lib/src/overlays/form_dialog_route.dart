import 'package:flutter/material.dart';
import 'package:nxgt_material/src/layout/window_size.dart';
import 'package:nxgt_material/src/overlays/form_dialog.dart';

/// The full-screen route: no animation under reduced motion.
class _FormRoute<T> extends MaterialPageRoute<T> {
  new({required super.builder, required this.reduceMotion})
    : super(fullscreenDialog: true);

  final bool reduceMotion;

  @override
  Duration get transitionDuration =>
      reduceMotion ? Duration.zero : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? Duration.zero : super.reverseTransitionDuration;
}

/// `context.showFormDialog`, shows a form in a dialog that fits the window.
extension FormDialogContext on BuildContext {
  /// Shows the form built by [builder] under [title] and returns the value
  /// [onSubmit] completed with, or `null` when the user closed it.
  ///
  /// On a compact window (under 600 dp) the form is full-screen, with a top
  /// app bar holding the close button, the title and the submit action. From
  /// the medium size up it is a dialog up to 560 dp wide with Cancel and the
  /// submit action at the bottom. The size is read when the dialog opens.
  ///
  /// The builder's content is placed in a `Form`; the submit action validates
  /// it (an invalid form stays open, nothing is sent), saves it and runs
  /// [onSubmit], which returns the value to pop. If [onSubmit] throws, the
  /// error is reported with [FlutterError.reportError] and the dialog stays
  /// open. When a field has changed, closing the dialog asks to discard the
  /// changes first; the answer "Cancel" keeps it open. Focus returns to the
  /// control that opened it.
  ///
  /// ```dart
  /// final created = await context.showFormDialog<Invoice>(
  ///   title: 'New invoice',
  ///   submitLabel: 'Create',
  ///   builder: (context) => InvoiceFields(controller: controller),
  ///   onSubmit: () => repository.create(controller.draft),
  /// );
  /// ```
  ///
  /// Throws without a `Navigator` above (any `MaterialApp` provides one).
  Future<T?> showFormDialog<T>({
    required String title,
    required WidgetBuilder builder,
    required Future<T> Function() onSubmit,
    String? submitLabel,
  }) {
    final fullscreen = windowSize == WindowSize.compact;
    final reduceMotion = MediaQuery.disableAnimationsOf(this);
    final dialog = FormDialog<T>(
      title: title,
      onSubmit: onSubmit,
      submitLabel: submitLabel,
      fullscreen: fullscreen,
      child: Builder(builder: builder),
    );
    if (!fullscreen) {
      return showDialog<T>(
        context: this,
        animationStyle: reduceMotion ? AnimationStyle.noAnimation : null,
        builder: (_) => dialog,
      );
    }
    final navigator = Navigator.of(this, rootNavigator: true);
    final themes = InheritedTheme.capture(from: this, to: navigator.context);
    return navigator.push(
      _FormRoute<T>(
        reduceMotion: reduceMotion,
        builder: (_) => themes.wrap(dialog),
      ),
    );
  }
}
