import 'dart:convert';
import 'package:repartir_frontend/models/request/jeunerequest.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
import 'package:repartir_frontend/services/api_service.dart';

class JeuneService {
  JeuneService({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;

  //register
 Future<Utilisateur?> registerJeune(JeuneRequest jeune) async {
    final response = await _api.post(
      '/utilisateurs/register',
      body: jsonEncode(jeune.toJson()),
    );

    if (response.statusCode == 201) {
      return _api.decodeJson(response, (data) => Utilisateur.fromJson(data));
    } else if (response.statusCode == 302) {
      throw Exception('Email déjà utilisé');
    } else {
      return _api.decodeJson(response, (data) => throw Exception(
          'Erreur lors de l\'inscription de l\'entreprise: ${response.statusCode}'));
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

    Future<void> associateDomaines(int userId, List<int> domaineIds) async {
    for (final domaineId in domaineIds) {
      final response = await _api.post(
        '/user-domaines/utilisateur/$userId/domaine/$domaineId',
      );
      _api.decodeJson(response, (data) => data);
    }
  }

  Future<List<Map<String, dynamic>>> getDomaines() async {
    final response = await _api.get('/domaines/lister');
    return _api.decodeJson(response, (data) {
      final list = data as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    });
  }
  
}
