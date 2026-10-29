// The example prints to the console on purpose.
// ignore_for_file: avoid_print

// A client with a bearer token that renews itself on a 401, then a typed call.
import 'package:nxgt_http/nxgt_http.dart';

/// Where the app keeps its tokens (a secure store in a real application).
class Session {
  String accessToken = 'expired-token';

  /// Asks the server for a new access token.
  Future<void> renew() async {
    accessToken = 'fresh-token';
  }
}

class User {
  const new(this.name);

  final String name;
}

User decodeUser(Object? json) =>
    User((json! as Map<String, Object?>)['name']! as String);

Future<void> main() async {
  final session = Session();

  final client = ApiClient(
    baseUrl: Uri.parse('https://api.example.com/v1/'),
    headers: {'accept-language': 'fr'},
    connectTimeout: const Duration(seconds: 10),
    // A 401 refreshes the token once, shared by all concurrent calls, then
    // the request is replayed.
    auth: AuthOptions(token: () => session.accessToken, refresh: session.renew),
    // GET, HEAD, OPTIONS, PUT and DELETE are sent again on a transient error.
    retry: const RetryOptions(),
    // One record per attempt; the authorization header is always redacted.
    logger: HttpLogger(sink: print),
  );

  try {
    final user = await client.get('/me', decode: decodeUser);
    print('Signed in as ${user.name}.');
  } on ApiError catch (error) {
    switch (error) {
      case StatusError(:final status):
        print('The server answered $status.');
      case TimeoutError(:final stage):
        print('Timed out while trying to ${stage.name}.');
      case NetworkError():
        print('No answer at all.');
      case DecodeError():
        print('The body is not what decode expects.');
      case CancelledError():
        print('Cancelled: not a failure.');
    }
  }
}
