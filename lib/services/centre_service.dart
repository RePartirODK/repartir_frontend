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
    try {
      debugPrint('Envoi de la requête d\'inscription: ${centre.toJson()}');
      final response = await _api.post(
        '/utilisateurs/register',
        body: centre.toJson(),
      );

      debugPrint('Réponse du serveur: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        debugPrint('Inscription réussie - parsing de la réponse');
        return _api.decodeJson(response, (data) => Utilisateur.fromJson(data));
      } else if (response.statusCode == 302) {
        debugPrint('Email déjà utilisé');
        throw Exception('Email déjà utilisé');
      } else if (response.statusCode == 400) {
        debugPrint('Données invalides');
        throw Exception('Données invalides. Veuillez vérifier les informations saisies.');
      } else if (response.statusCode == 500) {
        debugPrint('Erreur interne du serveur');
        throw Exception('Une erreur interne du serveur s\'est produite. Veuillez réessayer plus tard.');
      } else {
        debugPrint('Autre erreur: ${response.statusCode}');
        throw Exception('Autre erreur: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'inscription: $e');
      rethrow;
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
    try {
      debugPrint('Association des domaines pour l\'utilisateur $userId: $domaineIds');
      
      // Associer chaque domaine individuellement
      for (final domaineId in domaineIds) {
        try {
          debugPrint('Association du domaine $domaineId pour l\'utilisateur $userId');
          final response = await _api.post(
            '/user-domaines/utilisateur/$userId/domaine/$domaineId',
          );
          
          debugPrint('Réponse de l\'association: ${response.statusCode} - ${response.body}');
          
          if (response.statusCode >= 200 && response.statusCode < 300) {
            _api.decodeJson(response, (data) => data);
            debugPrint('Domaine $domaineId associé avec succès');
          } else {
            debugPrint('Erreur lors de l\'association du domaine $domaineId: ${response.statusCode}');
            throw Exception('Erreur lors de l\'association du domaine $domaineId');
          }
        } catch (domainError) {
          debugPrint('Erreur détaillée pour le domaine $domaineId: $domainError');
          throw domainError;
        }
      }
    } catch (e) {
      debugPrint('Erreur globale lors de l\'association des domaines: $e');
      rethrow;
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
