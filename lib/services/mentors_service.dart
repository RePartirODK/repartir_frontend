import 'package:repartir_frontend/services/api_service.dart';

class MentorsService {
  MentorsService({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;

  Future<List<Map<String, dynamic>>> listAll() async {
    final res = await _api.get('/mentors');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final res = await _api.get('/mentors/$id');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> mesMentors() async {
    final res = await _api.get('/mentors/mes-mentors');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}


