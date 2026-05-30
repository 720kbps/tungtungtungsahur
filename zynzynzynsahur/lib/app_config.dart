
class AppConfig {
  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sandbox.zynyo.com/api',
  );

  static const String apiKey = String.fromEnvironment('API_KEY');

  // OAuth / OpenID (access-token flow) 
  static const String clientId = String.fromEnvironment('CLIENT_ID');
  static const String clientSecret = String.fromEnvironment('CLIENT_SECRET');

  /// Full token endpoint from OpenID config ("token_endpoint"). realmId is in this URL
  static const String tokenEndpoint = String.fromEnvironment('TOKEN_ENDPOINT');

  /// "issuer" from OpenID config
  static const String issuer = String.fromEnvironment('ISSUER');

  static bool get isConfigured =>
      clientId.isNotEmpty &&
      clientSecret.isNotEmpty &&
      tokenEndpoint.isNotEmpty;

  /// Call once at startup (e.g. in main) to fail fast on a bad launch config.
  static void validate() {
    final missing = <String>[];
    if (clientId.isEmpty) missing.add('CLIENT_ID');
    if (clientSecret.isEmpty) missing.add('CLIENT_SECRET');
    if (tokenEndpoint.isEmpty) missing.add('TOKEN_ENDPOINT');
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing config: ${missing.join(', ')}. '
        'Run with: flutter run --dart-define-from-file=config/secrets.json',
      );
    }
  }
}