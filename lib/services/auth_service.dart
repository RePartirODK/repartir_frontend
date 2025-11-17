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

          // Sauvegarder l'ID utilisateur si présent dans la réponse
          if (loginResponse.id != null) {
            await _storage.saveId(loginResponse.id!);
            debugPrint('✅ ID utilisateur sauvegardé: ${loginResponse.id}');
          } else {
            debugPrint('⚠️ Aucun ID utilisateur dans la réponse de login');
          }

          return loginResponse;

        case 401:
        case 403:
          throw AuthException("Email ou mot de passe incorrect.");

          case 400:
         // Rendre le message explicite avec le détail renvoyé par le backend
         try {
           final err = jsonDecode(response.body);
           final msg = err['message'] ?? err['error'] ?? err['detail'] ?? 'Requête invalide.';
           throw AuthException("Requête invalide (400): $msg");
         } catch (_) {
           throw AuthException("Requête invalide (400). Vérifiez le format des identifiants et réessayez.");
         }


        case 500:
          try {
            final err = jsonDecode(response.body);
            final msg = err['message'] ?? err['error'] ?? err['detail'] ?? 'Erreur interne du serveur.';
            throw AuthException("Erreur interne du serveur (500): $msg");
          } catch (_) {
            throw AuthException("Erreur interne du serveur (500). Réessayez plus tard.");
          }

        
           default:
          try {
            final err = jsonDecode(response.body);
            final msg = err['message'] ?? err['error'] ?? err['detail'] ?? response.body;
            throw AuthException("Erreur (${response.statusCode}): $msg");
          } catch (_) {
            throw AuthException("Erreur (${response.statusCode}). Détails: ${response.body}");
          }}
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
