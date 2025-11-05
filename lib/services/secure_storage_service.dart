import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> saveUserInfo({
    required String role,
    required String email,
  }) async {
    await storage.write(key: 'user_role', value: role);
    await storage.write(key: 'user_email', value: email);
  }

  Future<void> saveId(int id) async {
    await storage.write(key: 'user_id', value: id.toString());
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<String?> getRefresToken() async {
    return await storage.read(key: 'refresh_token');
  }

  Future<String?> getUserRole() async {
    return await storage.read(key: 'user_role');
  }

  Future<String?> getUserEmail() async {
    return await storage.read(key: 'user_email');
  }

  Future<String?> getUserId() async {
    return await storage.read(key: 'user_id');
  }

  Future<void> clearTokens() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_role');
    await storage.delete(key: 'user_email');
    await storage.delete(key: 'user_id');
  }
}
