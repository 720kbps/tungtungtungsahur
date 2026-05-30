class AppConfig {
  // API
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
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
    if (apiBaseUrl.isEmpty || apiKey.isEmpty ||
        clientId.isEmpty || clientSecret.isEmpty ||
        tokenEndpoint.isEmpty || issuer.isEmpty){
      print("not validated");
    }
    else{
      print("validated");
    }
  }
}