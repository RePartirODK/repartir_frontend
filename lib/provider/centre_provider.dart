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
  Future<void> updateCentre(CentreRequest updatedCentre) async {
    try {
      final savedCentre = await _service.updateCentre(updatedCentre);
      state = savedCentre; // met à jour partout automatiquement
    } catch (e) {
      rethrow;
    }
  }

  /// Réinitialise le centre (utile au logout)
  void clear() => state = null;
}
