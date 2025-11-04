import 'dart:convert';

import 'package:http/http.dart' as http;

class UtilisateurService {
  static const String baseUrl = "http://localhost:8183/api/utilisateurs";
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
}
