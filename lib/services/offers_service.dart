import 'api_service.dart';

/// Service pour gérer les offres d'emploi
class OffersService {
  final ApiService _api;

  OffersService({ApiService? api}) : _api = api ?? ApiService();

  /// Rechercher des offres d'emploi
  /// 
  /// Paramètres optionnels:
  /// - q: terme de recherche
  /// - localisations: liste de localisations
  /// - typesContrat: liste de types (CDI, CDD, Stage, Freelance)
  /// - domaines: liste de domaines
  /// - niveauxExperience: liste de niveaux (Junior, Intermédiaire, Senior)
  /// - entrepriseIds: liste d'IDs d'entreprises
  /// - datePublicationMin: date minimale de publication
  /// - seulementAvecLienExterne: booléen
  /// - tri: mode de tri (recent, pertinence, salaire_desc)
  /// - page: numéro de page (défaut 1)
  /// - pageSize: taille de page (défaut 20)
  Future<List<Map<String, dynamic>>> search({
    String? q,
    List<String>? localisations,
    List<String>? typesContrat,
    List<String>? domaines,
    List<String>? niveauxExperience,
    List<String>? entrepriseIds,
    String? datePublicationMin,
    bool? seulementAvecLienExterne,
    String? tri,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (q != null) queryParams['q'] = q;
    if (localisations != null && localisations.isNotEmpty) {
      queryParams['localisations'] = localisations;
    }
    if (typesContrat != null && typesContrat.isNotEmpty) {
      queryParams['typesContrat'] = typesContrat;
    }
    if (domaines != null && domaines.isNotEmpty) {
      queryParams['domaines'] = domaines;
    }
    if (niveauxExperience != null && niveauxExperience.isNotEmpty) {
      queryParams['niveauxExperience'] = niveauxExperience;
    }
    if (entrepriseIds != null && entrepriseIds.isNotEmpty) {
      queryParams['entrepriseIds'] = entrepriseIds;
    }
    if (datePublicationMin != null) queryParams['datePublicationMin'] = datePublicationMin;
    if (seulementAvecLienExterne != null) queryParams['seulementAvecLienExterne'] = seulementAvecLienExterne;
    if (tri != null) queryParams['tri'] = tri;
    if (page != null) queryParams['page'] = page;
    if (pageSize != null) queryParams['pageSize'] = pageSize;

    final response = await _api.get('/offres/lister', query: queryParams);
    final List data = _api.decodeJson<List<dynamic>>(response, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Obtenir les détails d'une offre
  Future<Map<String, dynamic>> details(int offreId) async {
    final response = await _api.get('/offres/$offreId');
    return _api.decodeJson<Map<String, dynamic>>(response, (d) => d as Map<String, dynamic>);
  }
}
