import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:repartir_frontend/services/secure_storage_service.dart';

class UtilisateurService {
  static const String baseUrl = "http://localhost:8183/api/utilisateurs";
  final storage = SecureStorageService();
  //methode de suppression de compte
  Future<String?> suppressionCompte(Map<String, String> request) async {
    final url = Uri.parse('$baseUrl/supprimer');
    //appel du endpoint
    final response = await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request),
    );

    //verification de la réponse retournée par le backend
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception(
        'utilisateur avec l\'email ${request["email"]}'
        'non trouvé',
      );
    } else {
      throw Exception('Une erreur est survenue');
    }
  }


  //methode de logout
  Future<String?> logout(Map<String, String> request) async{
    final url = Uri.parse('http://localhost:8183/api/logout');
    final response = await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request),
    );
    if (response.statusCode == 200) {
      //on supprimer les tokens du stockage sécurisé
      storage.clearTokens();
      return jsonDecode(response.body);
    } else {
      throw Exception('Une erreur est survenue lors de la déconnexion');
    }
  }
}
