import 'package:repartir_frontend/services/api_service.dart';

class EntreprisesPublicService {
  EntreprisesPublicService({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;

  Future<List<Map<String, dynamic>>> listAll() async {
    final res = await _api.get('/entreprises');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}


