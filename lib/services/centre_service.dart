import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:repartir_frontend/models/request/centre_request.dart';
import 'package:repartir_frontend/models/request/request_formation.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/models/response/response_inscription.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
import 'package:repartir_frontend/services/api_service.dart';

class CentreService {
  final ApiService _api = ApiService();

  /// --- INSCRIPTION DU CENTRE ---
  Future<Utilisateur?> register(CentreRequest centre) async {
    final response = await _api.post(
      '/utilisateurs/register',
      body: jsonEncode(centre.toMap()),
    );

    if (response.statusCode == 201) {
      return _api.decodeJson(response, (data) => Utilisateur.fromJson(data));
    } else if (response.statusCode == 302) {
      throw Exception('Email déjà utilisé');
    } else {
      return _api.decodeJson(
        response,
        (data) => throw Exception(
          'Erreur lors de l\'inscription du centre: ${response.statusCode}\n'
          '${data['message']}',
        ),
      );
    }
  }

  /// --- CENTRE ACTUEL ---
  Future<ResponseCentre?> getCurrentCentre() async {
    final response = await _api.get('/centres/me');
    return _api.decodeJson(response, (data) => ResponseCentre.fromJson(data));
  }

  /// --- INSCRIPTIONS POUR UN CENTRE ---
  Future<List<ResponseInscription>> getCentreInscriptions(int centreId) async {
    final response = await _api.get('/inscriptions/centre/$centreId');
    return _api.decodeJson(response, (data) {
      final list = data as List<dynamic>;
      return list.map((e) => ResponseInscription.fromJson(e)).toList();
    });
  }

  /// --- FORMATIONS DU CENTRE ---
  Future<List<ResponseFormation>> getAllFormations(int centreId) async {
    final response = await _api.get('/formations/centre/$centreId');
    return _api.decodeJson(response, (data) {
      final list = data as List<dynamic>;
      return list.map((e) => ResponseFormation.fromJson(e)).toList();
    });
  }

  /// --- AJOUTER UNE FORMATION ---
  Future<ResponseFormation?> createFormation(
    RequestFormation request,
    int centreId,
  ) async {
    final response = await _api.post(
      '/formations/centre/$centreId',
      body: jsonEncode(request.toJson()),
    );
    return _api.decodeJson(
      response,
      (data) => ResponseFormation.fromJson(data),
    );
  }

  /// --- MISE À JOUR DU CENTRE ---
  Future<ResponseCentre?> updateCentre(CentreRequest updatedCentre) async {
    final response = await _api.put(
      '/utilisateurs/v1',
      body: jsonEncode(updatedCentre.toJson()),
    );
    return _api.decodeJson(response, (data) => ResponseCentre.fromJson(data));
  }

  /// --- INSCRIPTIONS POUR UNE FORMATION ---
  Future<List<ResponseInscription>> getInscriptionsByFormation(
    int formationId,
  ) async {
    final response = await _api.get('/inscriptions/formation/$formationId');
    return _api.decodeJson(response, (data) {
      final list = data as List<dynamic>;
      return list.map((e) => ResponseInscription.fromJson(e)).toList();
    });
  }

  Future<void> associateDomaines(int userId, List<int> domaineIds) async {
    for (final domaineId in domaineIds) {
      final response = await _api.post(
        '/user-domaines/utilisateur/$userId/domaine/$domaineId',
      );
      _api.decodeJson(response, (data) => data);
    }
  }

  /// --- METTRE À JOUR UNE FORMATION ---
  Future<ResponseFormation?> updateFormation(
    int id,
    RequestFormation request,
  ) async {
    final response = await _api.put(
      '/formations/$id',
      body: jsonEncode(request.toJson()),
    );
    return _api.decodeJson(
      response,
      (data) => ResponseFormation.fromJson(data),
    );
  }

  //suppression d'une formation
  Future<void> deleteFormation(int id) async {
    final response = await _api.delete('/formations/$id');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // delegate to decodeJson to throw a meaningful error
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

  /// --- CERTIFIER UNE INSCRIPTION ---
  Future<ResponseInscription?> certifierInscription(int inscriptionId) async {
    final response = await _api.patch('/inscriptions/$inscriptionId/certifier');
    return _api.decodeJson(
      response,
      (data) => ResponseInscription.fromJson(data),
    );
  }

  /// Annuler ou supprimer une formation selon présence d’inscriptions (motif requis)
  Future<void> cancelFormation(int id, String motif) async {
    final response = await _api.deleteV2('/formations/$id/annuler', query: { 'motif': motif });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _api.decodeJson(response, (data) => data);
    }
  }
}
