import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/request/parrain_request.dart';
import 'package:repartir_frontend/models/response/response_parrain.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
import 'package:repartir_frontend/network/api_config.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class ParrainService {
  static const String baseUrl = "http://localhost:8183/api/utilisateurs";
  final storage = SecureStorageService();
  //register parrain
  Future<Utilisateur?> registerParrain(ParrainRequest parrain) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/utilisateurs/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(parrain.toJson()),
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

  //recuperer les informations du parrain courant
  
  Future<ResponseParrain?> getCurrentCentre() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/parrains/me');
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
      final responseCentre = ResponseParrain.fromJson(data);
      return responseCentre;
    } else if (response.statusCode == 404) {
      throw Exception("utilisateur non trouvé");
    } else {
      throw Exception("une erreur est survenue");
    }
  }


  Future updateCentre(ParrainRequest updatedParrain) async {
    final url = Uri.parse('$baseUrl/v1');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await storage.getAccessToken()}',
      },
      body: jsonEncode(updatedParrain.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ResponseParrain.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception("utilisateur non trouvé");
    } else {
      throw Exception("une erreur est survenue");
    }
  }

}
