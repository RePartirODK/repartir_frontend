import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:repartir_frontend/models/request/centre_request.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/services/centre_service.dart';

// Fournit une instance unique de CentreService
final centreServiceProvider = Provider<CentreService>((ref) {
  return CentreService();
});

// Le provider principal du centre connecté
final centreNotifierProvider =
    StateNotifierProvider<CentreNotifier, ResponseCentre?>((ref) {
  final service = ref.read(centreServiceProvider);
  return CentreNotifier(service);
});


class CentreNotifier extends StateNotifier<ResponseCentre?> {
  final CentreService _service;
  CentreNotifier(this._service) : super(null);

  /// Charge le centre connecté depuis le backend
  Future<void> loadCurrentCentre() async {
    try {
      final centre = await _service.getCurrentCentre();
      state = centre;
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  /// Met à jour le profil du centre sur le backend et dans l'état local
  /// Si l'API échoue, met à jour au moins l'état local pour que l'utilisateur ne perde pas ses modifications
  Future<void> updateCentre(CentreRequest updatedCentre) async {
    try {
      final savedCentre = await _service.updateCentre(updatedCentre);
      state = savedCentre; // met à jour partout automatiquement
    } catch (e) {
      // Si l'API échoue, mettre à jour au moins l'état local
      // pour que l'utilisateur voie ses modifications même si l'API a un problème
      updateCentreLocally(updatedCentre);
      rethrow; // Renvoyer l'erreur pour que l'UI puisse afficher un message
    }
  }

  /// Met à jour l'état local avec un CentreRequest sans appeler l'API
  /// Utile après l'upload de photo quand l'API met déjà à jour la base de données
  void updateCentreLocally(CentreRequest updatedCentre) {
    if (state == null) {
      debugPrint('⚠️ updateCentreLocally: state est null, impossible de mettre à jour');
      return;
    }
    
    debugPrint('🔄 updateCentreLocally: Mise à jour de l\'état local (sans appel API)');
    debugPrint('   - Nouvelle URL photo: ${updatedCentre.urlPhoto}');
    
    // Créer un nouvel état avec les données mises à jour
    state = ResponseCentre(
      id: state!.id,
      nom: updatedCentre.nom,
      email: updatedCentre.email,
      telephone: updatedCentre.telephone,
      adresse: updatedCentre.adresse,
      agrement: updatedCentre.agrement,
      urlPhoto: updatedCentre.urlPhoto ?? state!.urlPhoto,
      role: state!.role,
      estActive: state!.estActive,
    );
    
    debugPrint('✅ updateCentreLocally: État mis à jour avec succès');
  }

  /// Réinitialise le centre (utile au logout)
  void clear() => state = null;
}
