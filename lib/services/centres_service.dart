import 'package:repartir_frontend/services/api_service.dart';

class CentresService {
  CentresService({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;

  Future<List<Map<String, dynamic>>> listAll() async {
    final res = await _api.get('/centres');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> listActifs() async {
    final res = await _api.get('/centres/actifs');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final res = await _api.get('/centres/$id');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getFormationsByCentre(int id) async {
    final res = await _api.get('/centres/$id/formations');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}


