import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:repartir_frontend/services/api_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class ProfileService {
  ProfileService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;
  final SecureStorageService _storage = SecureStorageService();

  /// Récupère le profil de l'utilisateur connecté selon son rôle
  Future<Map<String, dynamic>> getMe() async {
    try {
      // Récupérer le rôle depuis le storage
      final role = await _storage.getUserRole();
      print('👤 Récupération profil pour rôle: $role');
      
      // Utiliser l'endpoint /profile approprié selon le rôle
      String endpoint;
      switch (role) {
        case 'ROLE_MENTOR':
          endpoint = '/mentors/profile';
          break;
        case 'ROLE_ENTREPRISE':
          endpoint = '/entreprises/profile';
          break;
        case 'ROLE_JEUNE':
        default:
          endpoint = '/jeunes/profile';
          break;
      }
      
      print('👤 Endpoint: $endpoint');
      final res = await _api.get(endpoint);
      final profile = _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
      print('✅ Profil récupéré complet: $profile');
      print('✅ ID: ${profile['id']}, Prenom: ${profile['prenom']}');
      return profile;
    } catch (e) {
      print('❌ Erreur getMe: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> partial) async {
    final res = await _api.put('/jeunes/modifier', body: jsonEncode(partial));
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updatePhoto(List<int> imageBytes, String email) async {
    print('📸 Préparation upload photo...');
    print('📸 Taille fichier: ${imageBytes.length} bytes');
    print('📸 Email: $email');
    
    // Créer une requête multipart
    var uri = Uri.parse('${_api.apiBaseUrl}/utilisateurs/photoprofil');
    var request = http.MultipartRequest('POST', uri);
    
    // Ajouter l'authentification
    final token = await _api.storage.getAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Détecter le type MIME à partir des bytes
    String contentType = 'image/jpeg'; // par défaut
    if (imageBytes.length > 2) {
      if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
        contentType = 'image/jpeg';
      } else if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50) {
        contentType = 'image/png';
      }
    }
    
    print('📸 Content-Type détecté: $contentType');
    
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: contentType == 'image/png' ? 'profile.png' : 'profile.jpg',
        contentType: http_parser.MediaType.parse(contentType),
      ),
    );
    
    request.fields['email'] = email;
    
    debugPrint('📸 Envoi de la requête...');
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    // Tentative d'auto-refresh si le token a expiré pendant l'upload
    if (response.statusCode == 401) {
      try {
        final refreshToken = await _api.storage.getRefresToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshRes = await http.post(
            Uri.parse('${_api.apiBaseUrl}/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          );
          if (refreshRes.statusCode >= 200 && refreshRes.statusCode < 300) {
            final data = jsonDecode(utf8.decode(refreshRes.bodyBytes));
            final newAccess = data['access_token']?.toString();
            final newRefresh = (data['refresh_token'] ?? refreshToken).toString();
            if (newAccess != null && newAccess.isNotEmpty) {
              await _api.storage.saveTokens(newAccess, newRefresh);
              // Recréer et renvoyer la requête avec le nouveau token
              final retry = http.MultipartRequest('POST', uri)
                ..headers['Authorization'] = 'Bearer $newAccess'
                ..fields['email'] = email
                ..files.add(
                  http.MultipartFile.fromBytes(
                    'file',
                    imageBytes,
                    filename: contentType == 'image/png' ? 'profile.png' : 'profile.jpg',
                    contentType: http_parser.MediaType.parse(contentType),
                  ),
                );
              final retriedStream = await retry.send();
              response = await http.Response.fromStream(retriedStream);
            }
          }
        }
      } catch (_) {
        // Erreur transitoire: laisser la réponse 401 telle quelle (UI peut proposer un retry)
      }
    }
    
    debugPrint('📸 Réponse backend: ${response.statusCode}');
    debugPrint('📸 Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'message': response.body, 'success': true};
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}


