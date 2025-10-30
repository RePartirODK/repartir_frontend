import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:repartir_frontend/models/loginresponse.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/services/secure_storage_service.dart';

class AuthService {
  //recuperation du secure storage
  final storage = SecureStorageService();

  //base dir
  static const String baseUrl = 'http://localhost:8183/api/auth';

  //Methode de login
  Future<LoginResponse?> login(String email, String motDePasse) async {
    final url = Uri.parse('$baseUrl/login');

    //la reponse du backend
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
      {"email": email, "motDePasse": motDePasse},
    ));

    //on capte ce que le back nous retourne
    if (response.statusCode == 200) {
      //on decode le body en json
      final data = jsonDecode(response.body);

      //on fait un mapping vers LoginResponse
      final loginResponse = LoginResponse.fromJson(data);

      //on enregistre les données dans le local
      await storage.saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );
       final String firstRole = loginResponse.roles.isNotEmpty
            ? loginResponse.roles.first
            : '';

        await storage.saveUserInfo(role: firstRole, 
        email: loginResponse.email);

        return loginResponse;
    } else if (response.statusCode == 403) {
      throw Exception('Email ou mot de passe incorrect');
    } else {
      throw Exception('Erreur inattendue: ${response.statusCode}');
    }
  }


  Future<void> logout() async {
    await storage.clearTokens();
  }
}
