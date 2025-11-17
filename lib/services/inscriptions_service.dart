import 'package:repartir_frontend/services/api_service.dart';

class InscriptionsService {
  InscriptionsService({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;

  Future<Map<String, dynamic>> sInscrire(int formationId, {bool payerDirectement = false}) async {
    final res = await _api.post(
      '/inscriptions/s-inscrire/$formationId',
      query: { 'payerDirectement': payerDirectement },
    );
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> mesInscriptions() async {
    final res = await _api.get('/inscriptions/mes-inscriptions');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> listByFormation(int formationId) async {
    final res = await _api.get('/inscriptions/formation/$formationId');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}


