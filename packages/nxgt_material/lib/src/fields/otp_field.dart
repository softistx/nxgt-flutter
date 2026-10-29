import 'package:flutter/material.dart';
import 'package:nxgt_material/src/fields/otp_field_input.dart';
import 'package:nxgt_material/src/fields/otp_slots.dart';
import 'package:nxgt_material/src/fields/validators.dart';

/// A field for a one-time code: a row of digit slots over one real input.
///
/// For the code of a text message, an email or an authenticator app. It is
/// one text input with invisible text over [length] slots of 48 dp, so the
/// platform keeps pasting, the number pad and `AutofillHints.oneTimeCode`. A
/// screen reader sees one text field named [label].
///
/// Only digits are kept; a paste is stripped of everything else and cut at
/// [length]. The slots stay left to right in right-to-left layouts, like the
/// digits. [onCompleted] fires once each time the code becomes complete, and
/// never submits the form. Inside a `Form`, an incomplete code fails with a
/// localized message, and an empty one when [required]. The row is [length]
/// slots wide (328 dp for 6); the slots stay 48 dp high and narrow below 48 dp
/// wide when the field has less room. A programmatic change of the controller
/// that completes the code fires [onCompleted] too, before [onChanged].
class OtpField extends StatefulWidget {
  /// Creates an OtpField.
  const new({
    required this.label,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.helperText,
    this.autofocus = false,
    this.required = false,
    super.key,
  }) : assert(length > 0 && length <= 12, 'length must be 1 to 12');

  /// The label above the slots, read by screen readers.
  final String label;

  /// The number of digits of the code.
  final int length;

  /// Called with the code once it has [length] digits; again only after it
  /// went incomplete.
  final ValueChanged<String>? onCompleted;

  /// Called with the digits at every edit.
  final ValueChanged<String>? onChanged;

  /// Called by `FormState.save` with the digits.
  final FormFieldSetter<String>? onSaved;

  /// An extra validator, run after the built-in ones.
  final FormFieldValidator<String>? validator;

  /// Controls the digits.
  final TextEditingController? controller;

  /// The focus node of the input.
  final FocusNode? focusNode;

  /// Whether the field accepts input.
  final bool enabled;

  /// A hint shown under the slots while there is no error.
  final String? helperText;

  /// Whether the field takes focus when first shown.
  final bool autofocus;

  /// Whether an empty value is an error.
  final bool required;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  final _hasError = ValueNotifier<bool>(false);
  late bool _complete;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _complete = _controller.text.length >= widget.length;
    _controller.addListener(_onText);
    _focus.addListener(_refresh);
  }

  @override
  void didUpdateWidget(OtpField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _ownController)?.removeListener(_onText);
      _controller.addListener(_onText);
    }
    if (old.controller != widget.controller || old.length != widget.length) {
      _complete = _controller.text.length >= widget.length;
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_refresh);
      _focus.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _focus.removeListener(_refresh);
    _ownController?.dispose();
    _ownFocus?.dispose();
    _hasError.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _onText() {
    final complete = _controller.text.length >= widget.length;
    if (complete && !_complete) widget.onCompleted?.call(_controller.text);
    _complete = complete;
    setState(() {});
  }

  void _setError(bool has) {
    if (mounted) _hasError.value = has;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = Validators.of(context);
    final length = widget.length;
    final validator = v.compose([
      if (widget.required) v.required(),
      (value) => value == null || value.isEmpty || value.length >= length
          ? null
          : v.l10n.fieldsOtpIncomplete(length),
      widget.validator,
    ]);
    final width = otpSlotsWidth(length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: widget.enabled
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface.withValues(alpha: .38),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: Stack(
            children: [
              PositionedDirectional(
                start: 0,
                end: 0,
                top: 0,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _hasError,
                    builder: (context, hasError, _) => OtpSlots(
                      text: _controller.text,
                      length: length,
                      focused: _focus.hasFocus,
                      hasError: hasError,
                      enabled: widget.enabled,
                    ),
                  ),
                ),
              ),
              MergeSemantics(
                child: Semantics(
                  label: widget.label,
                  child: OtpInput(
                    controller: _controller,
                    focusNode: _focus,
                    length: length,
                    validator: validator,
                    onError: _setError,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    onChanged: widget.onChanged,
                    onSaved: widget.onSaved,
                    helperText: widget.helperText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
