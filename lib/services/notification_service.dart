import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/notification.dart';
import 'package:repartir_frontend/services/api_config.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class NotificationService {
  final SecureStorageService _storage = SecureStorageService();

  Future<String?> _getAuthHeaders() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    return 'Bearer $token';
  }

  // Récupérer les notifications non lues
  Future<List<Notification>> getNotificationsNonLues() async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationsNonLues}');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Notification.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Utilisateur non trouvé');
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw Exception('Erreur lors de la récupération des notifications');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Marquer une notification comme lue
  Future<bool> marquerCommeLue(int notificationId) async {
    final authHeader = await _getAuthHeaders();
    if (authHeader == null) throw Exception('Non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationsMarquerLue}/$notificationId/marquer-comme-lue');

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': authHeader},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Vous n\'êtes pas autorisé à modifier cette notification');
      } else if (response.statusCode == 404) {
        throw Exception('Notification ou utilisateur non trouvé');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur lors de la mise à jour de la notification');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

