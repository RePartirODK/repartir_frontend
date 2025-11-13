import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/response/loginresponse.dart';
import 'package:repartir_frontend/network/api_config.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storage = SecureStorageService();
  static final String _baseUrl = '${ApiConfig.baseUrl}/auth';

  /// Connexion utilisateur
  Future<LoginResponse?> login(String email, String motDePasse) async {
    final Uri url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email.trim(),
          "motDePasse": motDePasse.trim(),
        }),
      );

      // --- Traitement des réponses ---
      switch (response.statusCode) {
        case 200:
          final data = jsonDecode(response.body);
          final loginResponse = LoginResponse.fromJson(data);

          // Sauvegarde sécurisée
          await _storage.saveTokens(
            loginResponse.accessToken,
            loginResponse.refreshToken,
          );

          final String firstRole =
              (loginResponse.roles.isNotEmpty) ? loginResponse.roles.first : '';

          await _storage.saveUserInfo(
            role: firstRole,
            email: loginResponse.email,
          );

          return loginResponse;

        case 401:
        case 403:
          throw AuthException("Email ou mot de passe incorrect.");

        case 500:
          throw AuthException("Erreur interne du serveur. Réessayez plus tard.");

        default:
          throw AuthException(
              "Erreur inattendue (${response.statusCode}). Vérifiez votre connexion.");
      }
    } on http.ClientException catch (e) {
      debugPrint("Erreur réseau : $e");
      throw AuthException("Problème de connexion réseau.");
    } on FormatException catch (e) {
      debugPrint("Erreur de format JSON : $e");
      throw AuthException("Réponse du serveur invalide.");
    } catch (e) {
      debugPrint("Erreur inattendue : $e");
      throw AuthException("Une erreur est survenue. Réessayez plus tard.");
    }
  }

  /// Déconnexion utilisateur
  Future<void> logout() async {
    await _storage.clearTokens();
  }
}

/// Classe d’erreur personnalisée pour clarifier les exceptions
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
