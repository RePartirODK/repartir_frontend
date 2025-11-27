import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:repartir_frontend/services/api_service.dart';

/// Service pour gérer les relations de mentorat
class MentoringsService {
  MentoringsService({ApiService? api}) : _api = api ?? ApiService();
  final ApiService _api;

  /// Créer une demande de mentorat
  Future<Map<String, dynamic>> createMentoring(
    int idMentor, 
    int idJeune, 
    String? message, {
    String? objectif,
  }) async {
    // Limite de caractères pour la base de données (VARCHAR standard)
    const int maxObjectifLength = 255;
    
    // Tronquer l'objectif si nécessaire pour éviter l'erreur SQL
    String trimmedObjectif = (objectif ?? 'Développement de compétences professionnelles').trim();
    if (trimmedObjectif.length > maxObjectifLength) {
      trimmedObjectif = trimmedObjectif.substring(0, maxObjectifLength);
      debugPrint('⚠️ L\'objectif a été tronqué à $maxObjectifLength caractères');
    }
    
    // RequestMentoring du backend attend: description et objectif
    final bodyData = {
      'description': message ?? 'Je souhaiterais bénéficier de votre accompagnement pour progresser dans ma carrière.',
      'objectif': trimmedObjectif,
    };
    
    debugPrint('📨 POST /mentorings/create/$idMentor/$idJeune');
    debugPrint('📨 Body: $bodyData');
    
    final res = await _api.post(
      '/mentorings/create/$idMentor/$idJeune',
      body: jsonEncode(bodyData),
      extraHeaders: {'Content-Type': 'application/json'},
    );
    
    debugPrint('📨 Réponse: ${res.statusCode}');
    debugPrint('📨 Body: ${res.body}');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  /// Récupérer tous les mentorings d'un mentor
  Future<List<Map<String, dynamic>>> getMentorMentorings(int idMentor) async {
    final res = await _api.get('/mentorings/mentor/$idMentor');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Récupérer tous les mentorings d'un jeune
  Future<List<Map<String, dynamic>>> getJeuneMentorings(int idJeune) async {
    final res = await _api.get('/mentorings/jeune/$idJeune');
    final List data = _api.decodeJson<List<dynamic>>(res, (d) => d as List<dynamic>);
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Accepter un mentoring (MENTOR uniquement)
  Future<Map<String, dynamic>> accepterMentoring(int idMentoring) async {
    final res = await _api.patch('/mentorings/$idMentoring/accepter');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  /// Refuser un mentoring (MENTOR uniquement)
  Future<Map<String, dynamic>> refuserMentoring(int idMentoring) async {
    final res = await _api.patch('/mentorings/$idMentoring/refuser');
    return _api.decodeJson<Map<String, dynamic>>(res, (d) => d as Map<String, dynamic>);
  }

  /// Supprimer un mentoring
  Future<void> deleteMentoring(int idMentoring) async {
    await _api.delete('/mentorings/$idMentoring');
  }

  /// Attribuer une note au mentor
  Future<String> attribuerNoteMentor(int idMentoring, int note) async {
    final res = await _api.put('/mentorings/note/mentor/$idMentoring?note=$note');
    return res.body;
  }

  /// Le jeune note le mentor (PUT /api/mentorings/note/jeune/{id})
  Future<String> noterMentor(int idMentoring, int note) async {
    final res = await _api.put('/mentorings/note/jeune/$idMentoring?note=$note');
    return res.body;
  }

  /// Le mentor note le jeune (PUT /api/mentorings/note/mentor/{id})
  Future<String> noterJeune(int idMentoring, int note) async {
    final res = await _api.put('/mentorings/note/mentor/$idMentoring?note=$note');
    return res.body;
  }
}

