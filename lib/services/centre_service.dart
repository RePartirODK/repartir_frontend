import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/request/centre_request.dart';
import 'package:repartir_frontend/models/request/request_formation.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class CentreService {
  static const String baseUrl = "http://localhost:8183/api/utilisateurs";
  static const String baseUrl1 = 'http://localhost:8183/api/centres';
  final storage = SecureStorageService();
  //register centre de formation
  Future<Utilisateur?> register(CentreRequest centre) async {
    final url = Uri.parse('$baseUrl/register');
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
        'Erreur lors de l\'inscription du centre: ${response.statusCode}',
      );
    }
  }

  Future<ResponseCentre?> getCurrentCentre() async {
    final url = Uri.parse('$baseUrl1/me');
    final token = await storage.getAccessToken();
debugPrint('Token utilisé pour /me : $token');
    //backend call
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token}',
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

  //recupérer les formations du centre
  Future<List<ResponseFormation>> getAllFormations(int centreId) async {
    const String baseUrl = 'http://localhost:8183/api/formations';
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
      return data.map((element) => ResponseFormation
      .fromJson(element))
      .toList();
    }else {
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
    const String baseUrl = 'http://localhost:8183/api/formations';
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

  Future updateCentre(ResponseCentre updatedCentre) async {}

}
