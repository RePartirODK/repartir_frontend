import 'dart:convert';
import 'package:repartir_frontend/services/api_service.dart';

class PasswordForgetService {
  static const String baseUrl = 'http://localhost:8183/api/password';

  final ApiService _api = ApiService();

  Future<String> sendCode(String email) async {
    final res = await _api.post(
      '/password/forget',
      body: jsonEncode({'email': email}),
    );
    return _api.decodeJson(res, (d) =>  d['message'].toString());
  }
  Future<String> resetPassword({
    required String email,
    required String code,
    required String nouveauPassword,
  }) async {
    final res = await _api.post(
      '/password/reset',
      body: jsonEncode({
        'email': email,
        'code': code,
        'nouveauPassword': nouveauPassword,
      }),
    );
    return _api.decodeJson(res, (d) => d['message'].toString());
  }
}

