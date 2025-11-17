import 'dart:convert';
import 'package:repartir_frontend/models/request/entreprise_request.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
import 'package:repartir_frontend/services/api_service.dart';

class EntrepriseService {
   EntrepriseService({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;
   Future<Utilisateur?> register(EntrepriseRequest entreprise) async {
    final response = await _api.post(
      '/utilisateurs/register',
      body: jsonEncode(entreprise.toJson()),
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
