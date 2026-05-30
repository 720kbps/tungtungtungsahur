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
}
