import 'package:dio/dio.dart';
import '../app_config.dart';
import '../models/signRequest.dart';

class ZynyoService {
  // Singleton pattern
  static final ZynyoService _instance = ZynyoService._internal();
  factory ZynyoService() => _instance;
  ZynyoService._internal();

  final Dio _dio = Dio();
  String? _accessToken;

  // Step 1: Authentication
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

    try {
      // api call
      final response = await _dio.get(
        "${AppConfig.apiBaseUrl}/rest/v3/documents/PARTIALLY_VALIDATED,SIGNED,REJECTED/0/10", // Try single valid state first
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
}
