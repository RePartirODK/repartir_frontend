import 'dart:convert';
import 'package:repartir_frontend/services/api_service.dart';

/// Service pour gérer les demandes de parrainage
class ParrainagesService {
  ParrainagesService({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;

  /// Créer une demande de parrainage
  /// Le jeune demande un parrainage pour une formation
  Future<Map<String, dynamic>> creerDemande({
    required int idJeune,
    required int idFormation,
    int? idParrain, // Optionnel - peut être null si le jeune ne choisit pas de parrain spécifique
  }) async {
    final bodyData = {
      'idJeune': idJeune,
      'idParrain': idParrain,
      'idFormation': idFormation,
    };
    
    print('📨 POST /parrainages/creer');
    print('📨 Body: $bodyData');
    
    final res = await _api.post(
      '/parrainages/creer',
      body: jsonEncode(bodyData),
      extraHeaders: {'Content-Type': 'application/json'},
    );
    
    print('📨 Réponse: ${res.statusCode}');
    print('📨 Body: ${res.body}');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  /// Lister toutes les demandes de parrainage
  Future<List<Map<String, dynamic>>> listerTous() async {
    final res = await _api.get('/parrainages/lister');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Lister les demandes en attente (PARRAIN uniquement)
  Future<List<Map<String, dynamic>>> demandesEnAttente() async {
    final res = await _api.get('/parrainages/demandes-en-attente');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Accepter une demande de parrainage (PARRAIN uniquement)
  Future<Map<String, dynamic>> accepterDemande(int idParrainage, int idParrain) async {
    final res = await _api.post('/parrainages/$idParrainage/accepter/$idParrain');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }
}

