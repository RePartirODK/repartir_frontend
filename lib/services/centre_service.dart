import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/formation.dart';
import 'package:repartir_frontend/services/api_config.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class CentreService {
  final SecureStorageService _storage = SecureStorageService();

  Future<String?> _getAuthHeaders() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    return 'Bearer $token';
  }

  // Lister tous les centres
  Future<List<CentreFormation>> listerCentres() async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.centres}');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CentreFormation.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération des centres');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Lister les centres actifs
  Future<List<CentreFormation>> listerCentresActifs() async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.centresActifs}');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CentreFormation.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération des centres');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir un centre par ID
  Future<CentreFormation?> getCentreById(int id) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.centresParId}/$id');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CentreFormation.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Centre introuvable');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération du centre');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir un centre par email
  Future<CentreFormation?> getCentreByEmail(String email) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.centresParEmail}/$email');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CentreFormation.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Centre introuvable');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération du centre');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Lister les formations d'un centre
  Future<List<Formation>> listerFormationsParCentre(int centreId) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.centres}/$centreId/formations');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Formation.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Centre introuvable');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération des formations');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

