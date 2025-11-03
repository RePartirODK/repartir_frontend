import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class PasswordForgetService {
  static const String baseUrl = 'http://localhost:8183/api/password';

  Future<String?> sendCode(Map<String, String> request) async {
    //endpoint de l'api
    final url = Uri.parse('$baseUrl/forget');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request),
    );
    switch (response.statusCode) {
      case 200:
        return "Email Envoyé";
      case 400:
        throw Exception("Requête invalide ");
      case 403:
        throw Exception("Accès interdit");
      default:
        throw Exception("Erreur interne");
    }
  }

  Future<String?> resetPassword(Map<String, String> request) async {
    final url = Uri.parse('$baseUrl/reset');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.toString();
    } else if (response.statusCode == 400) {
      throw Exception("Requête invalide");
    } else {
      throw Exception("Une erreur s'est produite");
    }
  }
}
