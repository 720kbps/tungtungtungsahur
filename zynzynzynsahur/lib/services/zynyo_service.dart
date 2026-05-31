import 'package:dio/dio.dart';
import '../app_config.dart';

class ZynyoService {
  // Singleton pattern
  static final ZynyoService _instance = ZynyoService._internal();
  factory ZynyoService() => _instance;

  final Dio _dio = Dio();
  final Dio _authDio = Dio(); // Dedicated Dio instance for authentication to avoid recursion
  String? _accessToken;

  ZynyoService._internal() {
    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authorization header if token is available
        if (_accessToken != null) {
          options.headers['authorization'] = 'bearer $_accessToken';
        }
        // Add API Key which is required for Zynyo REST API
        options.headers['apikey'] = AppConfig.apiKey;
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle 401 Unauthorized errors (Token expired)
        if (e.response?.statusCode == 401) {
          // If the request has already been retried, don't try again to avoid infinite loops
          if (e.requestOptions.extra['retried'] == true) {
            return handler.next(e);
          }

          try {
            // Check if another request already refreshed the token while this one was waiting
            String? requestToken = e.requestOptions.headers['authorization'];
            if (requestToken != 'bearer $_accessToken') {
              // Token was already refreshed by another concurrent request, retry with the new token
              e.requestOptions.headers['authorization'] = 'bearer $_accessToken';
            } else {
              // Refresh the token
              await authenticate();
              e.requestOptions.headers['authorization'] = 'bearer $_accessToken';
            }

            // Mark the request as retried and fetch it again
            e.requestOptions.extra['retried'] = true;
            final response = await _dio.fetch(e.requestOptions);
            return handler.resolve(response);
          } catch (err) {
            // If re-authentication or retry fails, forward the error
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));
  }

  // Step 1: Authentication
  Future<void> authenticate() async {
    try {
      final response = await _authDio.post(
        AppConfig.tokenEndpoint,
        data: {
          'grant_type': 'client_credentials',
          'client_id': AppConfig.clientId,
          'client_secret': AppConfig.clientSecret,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      _accessToken = response.data['access_token'];
      print("Authentication Successful");
    } catch (e) {
      print("Authentication Failed: $e");
      rethrow;
    }
  }

  Future<int> getDocumentCount() async {
    // Check if we have a token initially. The interceptor will handle subsequent refreshes.
    if (_accessToken == null) await authenticate();

    try {
      final response = await _dio.get(
        "${AppConfig.apiBaseUrl}/rest/v3/documentssummary/PARTIALLY_VALIDATED,SIGNED,REJECTED",
      );

      final count = response.data['documentsCount'] ?? 0;
      return count;
    } on DioException catch (e) {
      print("API Error Response: ${e.response?.data}");
      rethrow;
    }
  }

  Future<List> getDocuments() async {
    if (_accessToken == null) await authenticate();

    try {
      final response = await _dio.get(
        "${AppConfig.apiBaseUrl}/rest/v3/documents/NOT_VALIDATED,PARTIALLY_VALIDATED,SIGNED,REJECTED/0/30",
      );

      return response.data;
    } on DioException catch (e) {
      print("API Error Response: ${e.response?.data}");
      rethrow;
    }
  }

  Future<String?> getSigningUrl(String publicUuid) async {
    // The standard Zynyo sandbox signing link structure:
    String link = "https://sandbox.zynyo.com/sign/$publicUuid";
    return link;
  }
}
