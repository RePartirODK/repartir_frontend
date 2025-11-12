import 'api_service.dart';

/// Service pour gérer les endpoints liés aux Mentors
class MentorService {
  final ApiService _api = ApiService();

  /// GET /api/mentors
  /// Récupère la liste de tous les mentors
  Future<List<Map<String, dynamic>>> getAllMentors() async {
    try {
      final res = await _api.get('/mentors');
      final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Erreur getAllMentors: $e');
      return [];
    }
  }

  /// GET /api/mentors/{id}
  /// Récupère les détails d'un mentor par son ID
  Future<Map<String, dynamic>> getMentorById(int id) async {
    try {
      final res = await _api.get('/mentors/$id');
      return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
    } catch (e) {
      print('❌ Erreur getMentorById: $e');
      rethrow;
    }
  }

  /// DELETE /api/mentors/{id}
  /// Supprime un mentor
  Future<void> deleteMentor(int id) async {
    try {
      await _api.delete('/mentors/$id');
    } catch (e) {
      print('❌ Erreur deleteMentor: $e');
      rethrow;
    }
  }

  // ============ MENTORINGS ============

  /// GET /api/mentorings/mentor/{idMentor}
  /// Récupère tous les mentorings d'un mentor
  Future<List<Map<String, dynamic>>> getMentorMentorings(int idMentor) async {
    try {
      final res = await _api.get('/mentorings/mentor/$idMentor');
      final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Erreur getMentorMentorings: $e');
      return [];
    }
  }

  /// PATCH /api/mentorings/{idMentoring}/accepter
  /// Accepte une demande de mentorat
  Future<Map<String, dynamic>> accepterMentoring(int idMentoring) async {
    final res = await _api.patch('/mentorings/$idMentoring/accepter');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  /// PATCH /api/mentorings/{idMentoring}/refuser
  /// Refuse une demande de mentorat
  Future<Map<String, dynamic>> refuserMentoring(int idMentoring) async {
    final res = await _api.patch('/mentorings/$idMentoring/refuser');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  /// PUT /api/mentorings/note/mentor/{idMentoring}?note=X
  /// Le mentor attribue une note au jeune
  Future<String> noterJeune(int idMentoring, int note) async {
    final response = await _api.put(
      '/mentorings/note/mentor/$idMentoring?note=$note',
    );
    return response.toString();
  }

  /// PUT /api/mentorings/note/jeune/{idMentoring}?note=X
  /// Le jeune attribue une note au mentor
  Future<String> noterMentor(int idMentoring, int note) async {
    final response = await _api.put(
      '/mentorings/note/jeune/$idMentoring?note=$note',
    );
    return response.toString();
  }

  /// DELETE /api/mentorings/{idMentoring}
  /// Supprime un mentoring
  Future<void> deleteMentoring(int idMentoring) async {
    await _api.delete('/mentorings/$idMentoring');
  }

  /// GET /api/mentorings/jeune/{idJeune}
  /// Récupère tous les mentorings d'un jeune
  Future<List<Map<String, dynamic>>> getJeuneMentorings(int idJeune) async {
    try {
      final res = await _api.get('/mentorings/jeune/$idJeune');
      final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Erreur getJeuneMentorings: $e');
      return [];
    }
  }
}
