import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/formation.dart';
import 'package:repartir_frontend/models/notification.dart';
import 'package:repartir_frontend/services/api_config.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class FormationService {
  final SecureStorageService _storage = SecureStorageService();

  Future<String?> _getAuthHeaders() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    return 'Bearer $token';
  }

  // Lister toutes les formations
  Future<List<Formation>> listerFormations() async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.formations}');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Formation.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération des formations');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir une formation par ID
  Future<Formation?> getFormationById(int id) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.formationsParId}/$id');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Formation.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Formation non trouvée');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération de la formation');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Lister les formations d'un centre
  Future<List<Formation>> listerFormationsParCentre(int centreId) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.formationsParCentre}/$centreId');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Formation.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération des formations');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Récupérer mes inscriptions (formations auxquelles le jeune est inscrit)
  Future<List<InscriptionResponse>> getMesInscriptions() async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mesInscriptions}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InscriptionResponse.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération des inscriptions');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // S'inscrire à une formation
  Future<InscriptionResponse> sinscrire(int formationId, {bool payerDirectement = false}) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.inscriptions}/$formationId?payerDirectement=$payerDirectement');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InscriptionResponse.fromJson(data);
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé — rôle non autorisé');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur interne lors de l\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

