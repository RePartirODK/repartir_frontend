import 'dart:convert';
import '../models/offre_emploi.dart';
import 'api_service.dart';

class OffreEmploiService {
  final ApiService _api = ApiService();

  /// Créer une nouvelle offre d'emploi (ENTREPRISE uniquement)
  Future<OffreEmploi> creerOffre(Map<String, dynamic> offreData) async {
    try {
      print('📝 Création d\'une nouvelle offre...');
      final response = await _api.post('/entreprises/offres/creer', body: jsonEncode(offreData));
      final data = _api.decodeJson<Map<String, dynamic>>(
        response,
        (d) => d as Map<String, dynamic>,
      );
      print('✅ Offre créée avec succès');
      return OffreEmploi.fromJson(data);
    } catch (e) {
      print('❌ Erreur création offre: $e');
      rethrow;
    }
  }

  /// Récupérer les offres de l'entreprise connectée
  Future<List<OffreEmploi>> getMesOffres() async {
    try {
      print('📋 Récupération de mes offres...');
      final response = await _api.get('/entreprises/offres');
      final data = _api.decodeJson<List<dynamic>>(response, (d) => d as List<dynamic>);
      
      final offres = data
          .map((json) => OffreEmploi.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ ${offres.length} offres récupérées');
      return offres;
    } catch (e) {
      print('❌ Erreur récupération offres: $e');
      rethrow;
    }
  }

  /// Supprimer une offre d'emploi
  Future<void> supprimerOffre(int offreId) async {
    try {
      print('🗑️ Suppression de l\'offre $offreId...');
      await _api.delete('/entreprises/offres/supprimer/$offreId');
      print('✅ Offre supprimée avec succès');
    } catch (e) {
      print('❌ Erreur suppression offre: $e');
      rethrow;
    }
  }

  /// Récupérer toutes les offres disponibles (pour les jeunes)
  Future<List<OffreEmploi>> getToutesLesOffres() async {
    try {
      print('📋 Récupération de toutes les offres...');
      final response = await _api.get('/offres/lister');
      final data = _api.decodeJson<List<dynamic>>(response, (d) => d as List<dynamic>);
      
      final offres = data
          .map((json) => OffreEmploi.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ ${offres.length} offres disponibles');
      return offres;
    } catch (e) {
      print('❌ Erreur récupération offres: $e');
      rethrow;
    }
  }

  /// Récupérer le détail d'une offre
  Future<OffreEmploi> getOffreById(int offreId) async {
    try {
      print('📋 Récupération détail offre $offreId...');
      final response = await _api.get('/offres/$offreId');
      final data = _api.decodeJson<Map<String, dynamic>>(
        response,
        (d) => d as Map<String, dynamic>,
      );
      print('✅ Détail offre récupéré');
      return OffreEmploi.fromJson(data);
    } catch (e) {
      print('❌ Erreur récupération détail offre: $e');
      rethrow;
    }
  }
}

