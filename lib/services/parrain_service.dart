import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:repartir_frontend/models/request/parrain_request.dart';
import 'package:repartir_frontend/models/response/response_parrain.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
import 'package:repartir_frontend/services/api_service.dart';

class ParrainService {
  final ApiService _api = ApiService();

  /// Register parrain
  Future<Utilisateur?> registerParrain(ParrainRequest parrain) async {
    try {
      final response = await _api.post(
        '/utilisateurs/register',
        body: jsonEncode(parrain.toJson()),
      );
      return _api.decodeJson(response, (data) => Utilisateur.fromJson(data));
    } catch (e) {
      if (e.toString().contains('302')) {
        throw Exception('Email déjà utilisé');
      }
      rethrow;
    }
  }

  /// Récupérer les informations du parrain courant
  Future<ResponseParrain?> getCurrentParrain() async {
    try {
      final response = await _api.get('/parrains/me');
      return _api.decodeJson(response, (data) => ResponseParrain.fromJson(data));
    } catch (e) {
      debugPrint('Erreur getCurrentParrain: $e');
      rethrow;
    }
  }

   /// Accepter une demande de parrainage (PARRAIN uniquement)
  Future<Map<String, dynamic>> accepterDemande(int idParrainage, int idParrain) async {
    final res = await _api.post('/parrainages/$idParrainage/accepter/$idParrain');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }
// ... existing code ...
  /// Lister les parrainages acceptés pour le parrain connecté (PARRAIN uniquement)
  Future<List<Map<String, dynamic>>> listerAcceptesPourMoi() async {
    final res = await _api.get('/parrainages/me/acceptes');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Mettre à jour le parrain
  Future<ResponseParrain?> updateParrain(ParrainRequest updatedParrain) async {
    try {
      final response = await _api.put(
        '/parrains/v1',
        body: jsonEncode(updatedParrain.toJson()),
      );
      return _api.decodeJson(response, (data) => ResponseParrain.fromJson(data));
    } catch (e) {
      debugPrint('Erreur updateParrain: $e');
      rethrow;
    }
  }

    /// Total des donations pour le parrain connecté
  Future<double> getTotalDonationsForMe() async {
    final res = await _api.get('/paiements/parrains/me/total');
    return _api.decodeJson<double>(res, (d) => (d as num).toDouble());
  }
}
