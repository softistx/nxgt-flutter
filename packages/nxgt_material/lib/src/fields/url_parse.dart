const _label = r'[\p{L}\p{N}](?:[\p{L}\p{N}-]{0,61}[\p{L}\p{N}])?';

final _url = RegExp(
  '^(?:https?://)?(?<host>$_label(?:\\.$_label)+)'
  r'(?::(?<port>\d{1,5}))?(?:[/?#]\S*)?$',
  caseSensitive: false,
  unicode: true,
);

final _scheme = RegExp('^https?://', caseSensitive: false);

/// Whether [text] (trimmed) is an http or https web address.
///
/// The scheme is optional and the host is a domain name (international
/// names included) with at least one dot and a last label holding a letter:
/// no bare IP, `localhost` or credentials. A port must be 1 to 65535. Internal:
/// apps use `Validators.url` and `UrlField.normalize`.
bool isWebUrl(String text) {
  final match = _url.firstMatch(text.trim());
  if (match == null) return false;
  // The last label must contain a letter: this rejects bare IPv4 hosts.
  final tld = match.namedGroup('host')!.split('.').last;
  if (!tld.contains(RegExp(r'\p{L}', unicode: true))) return false;
  final port = match.namedGroup('port');
  return port == null || (int.parse(port) >= 1 && int.parse(port) <= 65535);
}

/// [text] trimmed, with `https://` added when it has no scheme, or `null`
/// when it is not a web address.
String? normalizeWebUrl(String text) {
  final trimmed = text.trim();
  if (!isWebUrl(trimmed)) return null;
  return _scheme.hasMatch(trimmed) ? trimmed : 'https://$trimmed';
}
