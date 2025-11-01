import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/entreprise_request.dart';
import 'package:repartir_frontend/models/utilisateur.dart';

class EntrepriseService {
  static const String baseUrl = "http://localhost:8183/api/utilisateurs";
  Future<Utilisateur?> register(EntrepriseRequest entreprise) async {
    // Implementation to fetch centres
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(entreprise.toJson()),
    );

    if (response.statusCode == 201) {
      // Successfully registered entreprise
      return Utilisateur.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 302) {
      throw Exception('Email déjà utilisé');
    } else {
      throw Exception(
        'Erreur lors de l\'inscription de l\'entreprise: ${response.statusCode}',
      );
    }
  }
}
