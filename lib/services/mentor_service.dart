import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/mentor.dart';
import 'package:repartir_frontend/services/api_config.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/models/mentors_request.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
class MentorService {
  final SecureStorageService _storage = SecureStorageService();

  static const String baseUrl = "http://localhost:8183/api/utilisateurs";

  //register parrain
  Future<Utilisateur?> registerMentor(MentorsRequest mentor) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(mentor.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final utilisateur = Utilisateur.fromJson(data);
      return utilisateur;
    } else if (response.statusCode == 302) {
      throw Exception('Email déjà utilisé');
    } else {
      throw Exception(
        'Erreur lors de l\'inscription du jeune: ${response.statusCode}',
      );
    }
  }

  Future<String?> _getAuthHeaders() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    return 'Bearer $token';
  }

  // Lister tous les mentors
  Future<List<Mentor>> listerMentors() async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mentors}');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Mentor.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération des mentors');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir un mentor par ID
  Future<Mentor?> getMentorById(int id) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mentorsParId}/$id');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Mentor.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération du mentor');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Créer un mentoring
  Future<Mentoring> creerMentoring(int idMentor, int idJeune, CreateMentoringRequest request) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mentoringsCreate}/$idMentor/$idJeune');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Mentoring.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Mentor ou Jeune non trouvé');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Une erreur est survenue');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Lister les mentorings d'un jeune
  Future<List<Mentoring>> listerMentoringsParJeune(int idJeune) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mentoringsParJeune}/$idJeune');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Mentoring.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération des mentorings');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Noter le mentor
  Future<bool> noterMentor(int idMentoring, int note) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mentoringsNoteMentor}/$idMentoring?note=$note');

    try {
      final response = await http.put(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        throw Exception('Erreur lors de l\'attribution de la note');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la notation');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Noter le jeune
  Future<bool> noterJeune(int idMentoring, int note) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mentoringsNoteJeune}/$idMentoring?note=$note');

    try {
      final response = await http.put(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        throw Exception('Erreur lors de l\'attribution de la note');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la notation');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer un mentoring
  Future<bool> supprimerMentoring(int idMentoring) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mentoringsSupprimer}/$idMentoring');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la suppression');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}






