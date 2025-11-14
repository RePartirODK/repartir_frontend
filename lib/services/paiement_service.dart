import 'dart:convert';
import 'package:repartir_frontend/models/request/request_paiement.dart';
import 'package:repartir_frontend/models/response/response_paiement.dart';
import 'package:repartir_frontend/services/api_service.dart';

class PaiementService {
  final ApiService _api = ApiService();

  /// Créer un paiement
  Future<ResponsePaiement> creerPaiement(RequestPaiement request) async {
    final response = await _api.post(
      '/paiements/creer',
      body: jsonEncode(request.toJson()),
    );

    return _api.decodeJson(
      response,
      (data) => ResponsePaiement.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Valider un paiement (admin)
  Future<String> validerPaiement(int idPaiement) async {
    final response = await _api.put('/paiements/valider/$idPaiement');
    
    return _api.decodeJson(
      response,
      (data) => data.toString(),
    );
  }

  /// Refuser un paiement (admin)
  Future<String> refuserPaiement(int idPaiement) async {
    final response = await _api.put('/paiements/refuser/$idPaiement');
    
    return _api.decodeJson(
      response,
      (data) => data.toString(),
    );
  }

  /// Lister les paiements d'un jeune
  Future<List<ResponsePaiement>> getPaiementsByJeune(int idJeune) async {
    final response = await _api.get('/paiements/jeunes/$idJeune');
    
    return _api.decodeJson(
      response,
      (data) => (data as List)
          .map((item) => ResponsePaiement.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Lister les paiements d'une inscription
  Future<List<ResponsePaiement>> getPaiementsByInscription(int idInscription) async {
    final response = await _api.get('/paiements/inscription/$idInscription');
    
    return _api.decodeJson(
      response,
      (data) => (data as List)
          .map((item) => ResponsePaiement.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Récupérer le total des donations d'un parrain
  Future<double> getTotalDonationsByParrain() async {
    final response = await _api.get('/paiements/parrains/me/total');
    
    return _api.decodeJson(
      response,
      (data) => (data as num).toDouble(),
    );
  }
}


