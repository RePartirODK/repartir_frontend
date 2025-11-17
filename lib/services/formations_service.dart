import 'package:repartir_frontend/services/api_service.dart';

class FormationsService {
  FormationsService({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;

  Future<List<Map<String, dynamic>>> listAll() async {
    final res = await _api.get('/formations');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> listByCentre(int centreId) async {
    final res = await _api.get('/formations/centre/$centreId');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> details(int id) async {
    final res = await _api.get('/formations/$id');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }
}


