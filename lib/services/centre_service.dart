import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/request/centre_request.dart';
import 'package:repartir_frontend/models/request/request_formation.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/models/response/response_inscription.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
import 'package:repartir_frontend/network/api_config.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class CentreService {
  static const String baseUrl = "http://localhost:8183/api/utilisateurs";
  static final String baseUrl1 = '${ApiConfig.baseUrl}/centres';
  final storage = SecureStorageService();

  Future<Utilisateur?> register(CentreRequest centre) async {
    debugPrint("-------------url--------------${ApiConfig.baseUrl}/utilisateurs/register");
    final url = Uri.parse('${ApiConfig.baseUrl}/utilisateurs/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(centre.toMap()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final utilisateur = Utilisateur.fromJson(data);
      return utilisateur;
    } else if (response.statusCode == 302) {
      throw Exception('Email déjà utilisé');
    } else {
      throw Exception(
        'Erreur lors de l\'inscription du centre: ${response.statusCode}\n'
        '${jsonDecode(response.body)['message']}',
      );
    }
  }

  Future<ResponseCentre?> getCurrentCentre() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/centres/me');
    final token = await storage.getAccessToken();
    debugPrint('Token utilisé pour /me : $token');
    //backend call
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //mapping vers ResponseCentre
      final responseCentre = ResponseCentre.fromJson(data);
      return responseCentre;
    } else if (response.statusCode == 404) {
      throw Exception("utilisateur non trouvé");
    } else {
      throw Exception("une erreur est survenue");
    }
  }

  // New: list inscriptions (applicants) for all formations of a centre
  Future<List<ResponseInscription>> getCentreInscriptions(int centreId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/inscriptions/centre/$centreId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await storage.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ResponseInscription.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      throw Exception('Erreur lors du chargement des inscriptions du centre');
    }
  }
  //recupérer les formations du centre
  Future<List<ResponseFormation>> getAllFormations(int centreId) async {
    final String baseUrl = '${ApiConfig.baseUrl}/formations';
    final url = Uri.parse('$baseUrl/centre/$centreId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await storage.getAccessToken()}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((element) => ResponseFormation.fromJson(element))
          .toList();
    } else {
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      throw Exception('Erreur lors du chargement des formations');
    }
  }

  //ajouter une formation
  Future<ResponseFormation?> createFormation(
    RequestFormation request,
    int centreId,
  ) async {
    final String baseUrl = '${ApiConfig.baseUrl}/formations';
    final url = Uri.parse('$baseUrl/centre/$centreId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await storage.getAccessToken()}',
      },
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ResponseFormation.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception("utilisateur non trouvé");
    } else {
      throw Exception("une erreur est survenue");
    }
  }

  Future updateCentre(CentreRequest updatedCentre) async {
    final url = Uri.parse('$baseUrl/v1');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await storage.getAccessToken()}',
      },
      body: jsonEncode(updatedCentre.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ResponseCentre.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception("utilisateur non trouvé");
    } else {
      throw Exception("une erreur est survenue");
    }
  }

}
