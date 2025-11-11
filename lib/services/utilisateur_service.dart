import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/services/api_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class UtilisateurService {
  final ApiService _api = ApiService();
  final _storage = SecureStorageService();

  /// --- SUPPRESSION DU COMPTE ---
  Future<String?> suppressionCompte(Map<String, String> request) async {
    final response = await _api.delete(
      '/utilisateurs/supprimer',
      // `delete` dans ApiService peut être adapté pour accepter un body
      body: jsonEncode(request),
    );

    // Ici on utilise decodeJson pour gérer erreurs et décodage
    return _api.decodeJson(response, (data) => data.toString());
  }

  /// --- LOGOUT ---
  Future<void> logout(Map<String, String> request) async {
    final response = await _api.delete('/logout', body: jsonEncode(request));

    if (response.statusCode == 200) {
      // Supprimer tous les tokens locaux
      await _storage.clearTokens();
    } else {
      _api.decodeJson(
        response,
        (data) => throw Exception('Erreur lors de la déconnexion'),
      );
    }
  }

  /// --- UPLOAD PHOTO DE PROFIL ---
  Future<String?> uploadPhotoProfil(String email, String filePath) async {
    final url = Uri.parse('${_api.apiBaseUrl}/utilisateurs/photoprofil');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] =
            'Bearer ${await _api.storage.getAccessToken()}'
        ..fields['email'] = email
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        if (data['urlPhoto'] != null) return data['urlPhoto'];
        throw Exception(data['error'] ?? 'Erreur inconnue côté serveur');
      } else if (response.statusCode == 404) {
        throw Exception("Utilisateur non trouvé");
      } else {
        throw Exception(
          "Erreur lors du téléversement (${response.statusCode})",
        );
      }
    } catch (e) {
      throw Exception("Échec de l’upload : $e");
    }
  }
}
