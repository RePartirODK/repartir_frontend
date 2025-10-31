import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/jeunerequest.dart';
import 'package:repartir_frontend/models/utilisateur.dart';

class JeuneService {
  static const String baseUrl = "http://localhost:8183/api/utilisateurs";

  //register jeune
  Future<Utilisateur?> registerJeune(JeuneRequest jeune) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(jeune.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final utilisateur = Utilisateur.fromJson(data);
      return utilisateur;
    } else if (response.statusCode == 302) {
      throw Exception('Email déjà utilisé');
    } else {
      throw Exception(
        'Erreur lors de l\'inscription du jeune: ${response.statusCode}',
      );
    }
  }
}
