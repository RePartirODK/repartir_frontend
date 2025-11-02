import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/jeune_profil.dart';
import 'package:repartir_frontend/services/api_config.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class JeuneService {
  final SecureStorageService _storage = SecureStorageService();

  Future<String?> _getAuthHeaders() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    return 'Bearer $token';
  }

  // Récupérer le profil du jeune connecté
  Future<JeuneProfil?> getProfile() async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.jeunesProfile}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JeuneProfil.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Jeune non trouvé');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération du profil');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Modifier le profil
  Future<JeuneProfil?> modifierProfil(JeuneProfil profil) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.jeunesModifier}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profil.toUpdateJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JeuneProfil.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Jeune introuvable');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la mise à jour du profil');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer le compte
  Future<bool> supprimerCompte() async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.jeunesSupprimer}');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé (non autorisé)');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la suppression du compte');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Upload photo de profil
  Future<String> uploadPhotoProfil(String email, List<int> fileBytes, String fileName) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadPhotoProfil}');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = authHeader;
      
      request.fields['email'] = email;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 400) {
        throw Exception('Format de fichier non supporté');
      } else if (response.statusCode == 404) {
        throw Exception('Email incorrect');
      } else if (response.statusCode == 413) {
        throw Exception('Fichier trop volumineux');
      } else {
        throw Exception('Erreur lors de l\'upload');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

