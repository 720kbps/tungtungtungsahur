import 'package:dio/dio.dart';
import '../app_config.dart';

class ZynyoService {
  // Singleton pattern
  static final ZynyoService _instance = ZynyoService._internal();
  factory ZynyoService() => _instance;
  ZynyoService._internal();

  final Dio _dio = Dio();
  String? _accessToken;

  Future<void> authenticate() async {
    try {
      final response = await _dio.post(
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
    if (_accessToken == null) await authenticate();

    try {
      // api call
      final response = await _dio.get(
        "${AppConfig.apiBaseUrl}/rest/v3/documentssummary/PARTIALLY_VALIDATED,SIGNED,REJECTED", // Try single valid state first
        options: Options(
          headers: {
            'authorization': 'bearer $_accessToken',
            'apikey': AppConfig.apiKey, // Some Zynyo endpoints require the apikey as well
          },
        ),
      );

      final count = response.data['documentsCount'] ?? 0;
      print(response.data);
      return count;
    } on DioException catch (e) {
      print("API Error Response: ${e.response?.data}");
      rethrow;
    }
  }

  Future<List> getDocuments() async {
    if (_accessToken == null) await authenticate();
    int count = await getDocumentCount();
    try {
      // api call
      final response = await _dio.get(
        "${AppConfig.apiBaseUrl}/rest/v3/documents/NOT_VALIDATED,PARTIALLY_VALIDATED,SIGNED,REJECTED/0/$count", // Try single valid state first
        options: Options(
          headers: {
            'authorization': 'bearer $_accessToken',
            'apikey': AppConfig.apiKey, // Some Zynyo endpoints require the apikey as well
          },
        ),
      );

      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print("API Error Response: ${e.response?.data}");
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getDocumentStatus(String uuid) async {
    if (_accessToken == null) await authenticate();

    try {
      final response = await _dio.get(
        "${AppConfig.apiBaseUrl}/rest/v3/document/$uuid",
        options: Options(
          headers: {
            'authorization': 'bearer $_accessToken',
            'apikey': AppConfig.apiKey,
          },
        ),
      );

      return response.data["documentState"];
    } on DioException catch (e) {
      print("API Error Response: ${e.response?.data}");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSignedDocument(String uuid) async {
    if (_accessToken == null) await authenticate();

    try {
      final response = await _dio.get(
        "${AppConfig.apiBaseUrl}/rest/v3/sign/getsigned/$uuid",
        options: Options(
          headers: {
            'authorization': 'bearer $_accessToken',
            'apikey': AppConfig.apiKey,
          },
        ),
      );

      return response.data["documentContent"];
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
