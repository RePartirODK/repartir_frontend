import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:repartir_frontend/services/api_service.dart';

class ProfileService {
  ProfileService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<Map<String, dynamic>> getMe() async {
    final res = await _api.get('/jeunes/profile');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
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
      // Vérifier les magic numbers
      if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
        contentType = 'image/jpeg';
      } else if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50) {
        contentType = 'image/png';
      }
    }
    
    print('📸 Content-Type détecté: $contentType');
    
    // Ajouter le fichier avec le bon Content-Type
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: contentType == 'image/png' ? 'profile.png' : 'profile.jpg',
        contentType: http_parser.MediaType.parse(contentType),
      ),
    );
    
    // Ajouter l'email
    request.fields['email'] = email;
    
    print('📸 Envoi de la requête...');
    
    // Envoyer la requête
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    print('📸 Réponse backend: ${response.statusCode}');
    print('📸 Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'message': response.body, 'success': true};
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}


