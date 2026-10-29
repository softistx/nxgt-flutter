final _url = RegExp(
  '^(?:https?://)?'
  '[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
  r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+'
  r'(?::\d{1,5})?(?:[/?#]\S*)?$',
  caseSensitive: false,
);

final _scheme = RegExp('^https?://', caseSensitive: false);

/// Whether [text] (trimmed) is an http or https web address.
///
/// The scheme is optional and the host needs at least one dot. Internal:
/// apps use `Validators.url` and `UrlField.normalize`.
bool isWebUrl(String text) => _url.hasMatch(text.trim());

/// [text] trimmed, with `https://` added when it has no scheme, or `null`
/// when it is not a web address.
String? normalizeWebUrl(String text) {
  final trimmed = text.trim();
  if (!isWebUrl(trimmed)) return null;
  return _scheme.hasMatch(trimmed) ? trimmed : 'https://$trimmed';
}
