import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/main.dart' show navigatorKey;
import 'package:repartir_frontend/network/api_config.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final SecureStorageService _storage = SecureStorageService();

  SecureStorageService get storage => _storage;
  String get apiBaseUrl => ApiConfig.baseUrl;

  /// --- Crée les headers avec ou sans token ---
  Future<Map<String, String>> _authHeaders({
    Map<String, String>? extra,
    bool requireAuth = false,
  }) async {
    final token = await _storage.getAccessToken();
    if (requireAuth && token == null) {
      throw Exception('Authentification requise. Veuillez vous connecter.');
    }
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  /// --- GET ---
  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
   final uri = Uri.parse('$apiBaseUrl$path').replace(queryParameters: _encodeQuery(query));
    return _executeWithAutoRefresh(() async {
      final headers = await _authHeaders();
      return _client.get(uri, headers: headers);
    });
  }

  /// --- POST ---
  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? query,
  }) async {

      final uri = Uri.parse('$apiBaseUrl$path').replace(queryParameters: _encodeQuery(query));
    return _executeWithAutoRefresh(() async {
      final headers = await _authHeaders(extra: extraHeaders);
      return _client.post(uri, headers: headers, body: body);
    });
    
  }

  /// --- PUT ---
  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? extraHeaders,
  }) async {


     final uri = Uri.parse('$apiBaseUrl$path');
    return _executeWithAutoRefresh(() async {
      final headers = await _authHeaders();
      return _client.put(uri, headers: headers, body: body);
    });
  
  }

  /// --- PATCH ---
  Future<http.Response> patch(String path, {Object? body}) async {
    final uri = Uri.parse('$apiBaseUrl$path');
    final headers = await _authHeaders();
    return _executeWithAutoRefresh(() async {
      return _client.patch(uri, headers: headers, body: body);
    });
  }

  /// --- DELETE avec body optionnel ---
  Future<http.Response> delete(String path, {Object? body}) async {
 return _executeWithAutoRefresh(() async {
   final uri = Uri.parse('$apiBaseUrl$path');
      final headers = await _authHeaders();
      if (body != null) {
        return _client
            .send(
              http.Request('DELETE', uri)
                ..headers.addAll(headers)
                ..body = body is String ? body : jsonEncode(body),
            )
            .then(http.Response.fromStream);
      }
      return _client.delete(uri, headers: headers);
    });
  
  }

  Future<http.Response> deleteV2(String path, {Object? body, Map<String, dynamic>? query}) async {
    return _executeWithAutoRefresh(() async {
      final uri = Uri.parse('$apiBaseUrl$path').replace(queryParameters: _encodeQuery(query));
      final headers = await _authHeaders();
      if (body != null) {
        return _client
            .send(
              http.Request('DELETE', uri)
                ..headers.addAll(headers)
                ..body = body is String ? body : jsonEncode(body),
            )
            .then(http.Response.fromStream);
      }
      return _client.delete(uri, headers: headers);
    });
  }

  

  /// --- MULTIPART pour upload de fichiers ---
  Future<http.StreamedResponse> multipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final uri = Uri.parse('$apiBaseUrl$path');
    final token = await _storage.getAccessToken();
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll(fields);
    request.files.addAll(files);
    return request.send();
  }

  /// --- Décodage JSON + gestion des erreurs ---
  T decodeJson<T>(http.Response response, T Function(dynamic) mapper) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      return mapper(data);
    }

    // Gestion des erreurs d'authentification
    if (response.statusCode == 401) {
      _handleAuthError();
    throw Exception('SESSION_EXPIRED');
    }
   if (response.statusCode == 403) {
      // Ne pas déconnecter l'utilisateur pour un 403 (rôle/permission)
      throw Exception('FORBIDDEN');
    }

    // Autres erreurs
    try {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      final message =
          errorBody['message'] ?? errorBody['error'] ?? 'Erreur inconnue';
      String safeMessage = message.toString();
      if (safeMessage.contains('JWT') || safeMessage.contains('eyJ')) {
        safeMessage = 'Erreur d\'authentification. Veuillez vous reconnecter.';
      }
      throw Exception('HTTP ${response.statusCode}: $safeMessage');
    } catch (_) {
      String body = response.body;
      if (body.contains('JWT') || body.contains('eyJ')) {
        body = 'Erreur d\'authentification. Veuillez vous reconnecter.';
      }
      throw Exception('HTTP ${response.statusCode}: $body');
    }
  }

  /// --- Gestion du token expiré ---
  void _handleAuthError() async {
    await _storage.clearTokens();
    final context = navigatorKey.currentContext;
    if (context != null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Map<String, String>? _encodeQuery(Map<String, dynamic>? q) {
    if (q == null) return null;
    final Map<String, String> out = {};
    q.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        for (final v in value) {
          out['$key[]'] = v.toString();
        }
      } else {
        out[key] = value.toString();
      }
    });
    return out;
  }

  /// --- Vérifie si le token existe ---
  Future<bool> hasToken() async {
    final token = await _storage.getAccessToken();
    return token != null && token.isNotEmpty;
  }


   /// --- Auto-refresh access token on 401 and retry the request ---
  Future<http.Response> _executeWithAutoRefresh(
    Future<http.Response> Function() send,
  ) async {
    final response = await send();
    if (response.statusCode != 401) return response;
    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      _handleAuthError(); // fall back to logout
      return response;
    }
    // Retry the original request with new token
    return await send();
  }

  /// --- Call /auth/refresh to renew the access token ---
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _storage.getRefresToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;
      final url = Uri.parse('$apiBaseUrl/auth/refresh');
      final res = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final newAccess = data['access_token']?.toString();
        final newRefresh = (data['refresh_token'] ?? refreshToken).toString();
        if (newAccess == null || newAccess.isEmpty) return false;
        await _storage.saveTokens(newAccess, newRefresh);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
