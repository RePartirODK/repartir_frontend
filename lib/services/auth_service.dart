import 'package:repartir_frontend/models/response/loginresponse.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/network/api_config.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class AuthService {
  //recuperation du secure storage
  final storage = SecureStorageService();

  //base dir
  static final String baseUrl = '${ApiConfig.baseUrl}/auth';

  //Methode de login
  Future<LoginResponse?> login(String email, String motDePasse) async {
    final url = Uri.parse('$baseUrl/login');

    //la reponse du backend
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "motDePasse": motDePasse}),
    );

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

      await storage.saveUserInfo(role: firstRole, email: loginResponse.email);
      
      // ✅ Sauvegarder le userId si disponible dans la réponse
      if (loginResponse.id != null) {
        await storage.saveId(loginResponse.id!);
        print('✅ UserId sauvegardé depuis login: ${loginResponse.id}');
      } else {
        print('⚠️ Le backend ne renvoie pas l\'ID utilisateur dans la réponse de login !');
        print('⚠️ Le chat ne pourra pas différencier les messages envoyés des messages reçus.');
      }

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
