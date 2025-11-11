import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/request/jeunerequest.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
import 'package:repartir_frontend/network/api_config.dart';
import 'package:repartir_frontend/services/api_service.dart';

class JeuneService {
  static const String baseUrl = "http://localhost:8183/api/utilisateurs";
  final ApiService _api = ApiService();
  //register jeune
  Future<Utilisateur?> registerJeune(JeuneRequest jeune) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/utilisateurs/register');
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

  /// Lister tous les jeunes (auth requis selon sécurité globale)
  Future<List<Map<String, dynamic>>> listAll() async {
    final res = await _api.get('/jeunes');
    final List data = _api.decodeJson<List<dynamic>>(
      res,
      (d) => d as List<dynamic>,
    );
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
