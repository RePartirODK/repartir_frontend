import 'package:flutter_riverpod/legacy.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/services/centre_service.dart';

final centreService = CentreService();

final formationProvider =
    StateNotifierProvider<FormationNotifier, List<ResponseFormation>>(
  (ref) => FormationNotifier(),
);

class FormationNotifier extends StateNotifier<List<ResponseFormation>> {
  FormationNotifier() : super([]);

  Future<void> loadFormations(int centreId) async {
    final formations = await centreService.getAllFormations(centreId);
    // Trier par ID décroissant (les plus récentes en premier - ID plus élevé = plus récent)
    formations.sort((a, b) => b.id.compareTo(a.id));
    state = formations;
  }

  void addFormation(ResponseFormation newFormation) {
    state = [...state, newFormation];
  }
}
