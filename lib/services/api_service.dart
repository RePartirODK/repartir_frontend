import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/main.dart' show navigatorKey;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final SecureStorageService _storage = SecureStorageService();

  static const String baseUrl = 'http://localhost:8183/api';
  
  // Getters pour accès externe
  SecureStorageService get storage => _storage;
  String get apiBaseUrl => baseUrl;

  Future<Map<String, String>> _authHeaders({Map<String, String>? extra, bool requireAuth = false}) async {
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
  
  Future<bool> hasToken() async {
    final token = await _storage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: _encodeQuery(query));
  }

  Map<String, String>? _encodeQuery(Map<String, dynamic>? q) {
    if (q == null) return null;
    final Map<String, String> out = {};
    q.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        // Use repeated parameters e.g. key[]=a&key[]=b
        for (final v in value) {
          out['$key[]'] = v.toString();
        }
      } else {
        out[key] = value.toString();
      }
    });
    return out;
  }

  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    final headers = await _authHeaders();
    return _client.get(_uri(path, query), headers: headers);
  }

  Future<http.Response> post(String path, {Object? body, Map<String, String>? extraHeaders, Map<String, dynamic>? query}) async {
    final headers = await _authHeaders(extra: extraHeaders);
    return _client.post(_uri(path, query), headers: headers, body: body);
  }

  Future<http.Response> patch(String path, {Object? body}) async {
    final headers = await _authHeaders();
    return _client.patch(_uri(path), headers: headers, body: body);
  }

  Future<http.Response> put(String path, {Object? body, Map<String, String>? extraHeaders}) async {
    final headers = await _authHeaders(extra: extraHeaders);
    return _client.put(_uri(path), headers: headers, body: body);
  }

  Future<http.Response> delete(String path) async {
    final headers = await _authHeaders();
    return _client.delete(_uri(path), headers: headers);
  }

  T decodeJson<T>(http.Response response, T Function(dynamic) mapper) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      return mapper(data);
    }
    
    // Gestion des erreurs d'authentification (401, 403) - Redirection automatique
    if (response.statusCode == 401 || response.statusCode == 403) {
      print('🔐 Token expiré ou accès refusé (${response.statusCode}) - Redirection vers login...');
      _handleAuthError();
      throw Exception('SESSION_EXPIRED'); // Exception spéciale
    }
    
    // Autres erreurs
    try {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      final message = errorBody['message'] ?? errorBody['error'] ?? 'Erreur inconnue';
      // Éviter d'afficher le token JWT dans l'erreur
      String safeMessage = message.toString();
      if (safeMessage.contains('JWT') || safeMessage.contains('eyJ')) {
        safeMessage = 'Erreur d\'authentification. Veuillez vous reconnecter.';
      }
      throw Exception('HTTP ${response.statusCode}: $safeMessage');
    } catch (_) {
      String body = response.body;
      // Éviter d'afficher le token JWT dans le body
      if (body.contains('JWT') || body.contains('eyJ')) {
        body = 'Erreur d\'authentification. Veuillez vous reconnecter.';
      }
      throw Exception('HTTP ${response.statusCode}: $body');
    }
  }

  /// Gérer l'expiration du token - Déconnexion et redirection
  void _handleAuthError() async {
    print('🚪 Déconnexion automatique...');
    
    // Nettoyer tous les tokens
    await _storage.clearTokens();
    
    // Rediriger vers la page de login
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Fermer toutes les pages et aller au login
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}









