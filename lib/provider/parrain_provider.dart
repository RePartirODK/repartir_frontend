import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:repartir_frontend/models/response/response_parrain.dart';
import 'package:repartir_frontend/models/request/parrain_request.dart';
import 'package:repartir_frontend/services/parrain_service.dart';

final parrainServiceProvider = Provider<ParrainService>((ref) {
  return ParrainService();
});

final parrainNotifierProvider =
    StateNotifierProvider<ParrainNotifier, ResponseParrain?>((ref) {
  final service = ref.read(parrainServiceProvider);
  return ParrainNotifier(service);
});

class ParrainNotifier extends StateNotifier<ResponseParrain?> {
  final ParrainService _service;
  ParrainNotifier(this._service) : super(null);

  Future<void> loadCurrentParrain() async {
    try {
      final parrain = await _service.getCurrentParrain();
      state = parrain;
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  Future<void> updateParrain(ParrainRequest updated) async {
    try {
      final saved = await _service.updateParrain(updated);
      state = saved;
    } catch (e) {
      // Si l'API échoue, mettre à jour au moins l'état local
      updateParrainLocally(updated);
      rethrow;
    }
  }

  /// Met à jour l'état local avec un ParrainRequest sans appeler l'API
  /// Utile après l'upload de photo quand l'API met déjà à jour la base de données
  void updateParrainLocally(ParrainRequest updated) {
    if (state == null) return;
    
    state = ResponseParrain(
      id: state!.id,
      nom: updated.nom,
      prenom: updated.prenom,
      email: updated.email,
      telephone: updated.telephone,
      profession: updated.profession ?? state!.profession,
      urlPhoto: updated.urlPhoto ?? state!.urlPhoto,
      utilisateur: state!.utilisateur, // Garder les données utilisateur existantes
      role: state!.role,
      dateInscription: state!.dateInscription,
    );
  }

  void clear() => state = null;
}