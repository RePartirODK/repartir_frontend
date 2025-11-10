import 'package:repartir_frontend/services/mentorings_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'dart:convert';

/// Service pour gérer les notifications basées sur les mentorings
class NotificationsService {
  final MentoringsService _mentorings = MentoringsService();
  final ProfileService _profile = ProfileService();
  final SecureStorageService _storage = SecureStorageService();

  static const String _notifKey = 'last_seen_mentorings';

  /// Récupérer les notifications de mentorat
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      // Récupérer l'ID du jeune
      final me = await _profile.getMe();
      final jeuneId = me['id'] as int;
      print('🔔 ID du jeune: $jeuneId');

      // Récupérer tous les mentorings du jeune
      final mentorings = await _mentorings.getJeuneMentorings(jeuneId);
      print('🔔 Nombre de mentorings récupérés: ${mentorings.length}');
      
      if (mentorings.isNotEmpty) {
        print('🔔 Premier mentoring: ${mentorings[0]}');
      }

      // Récupérer les derniers statuts vus
      final lastSeen = await _getLastSeenMentorings();
      print('📋 Derniers statuts vus: $lastSeen');

      // Créer des notifications pour les changements de statut
      final notifications = <Map<String, dynamic>>[];

      for (var mentoring in mentorings) {
        final id = mentoring['id'];
        
        // DEBUG: Afficher toutes les clés du mentoring
        print('🔍 Mentoring $id - Toutes les clés: ${mentoring.keys.toList()}');
        print('🔍 Valeurs: statut=${mentoring['statut']}, etat=${mentoring['etat']}');
        
        final statut = mentoring['statut'] ?? mentoring['etat'] ?? 'EN_ATTENTE';
        final mentor = mentoring['mentor'] ?? {};
        final utilisateur = mentor['utilisateur'] ?? {};
        final nomMentor = utilisateur['nom'] ?? 'Mentor';
        final dateDebut = mentoring['date_debut'] ?? mentoring['dateDebut'];

        // Vérifier si c'est un nouveau statut
        final lastStatus = lastSeen['$id'];
        final isNew = lastStatus == null || lastStatus != statut;
        
        print('📋 Mentoring $id: statut=$statut, lastStatus=$lastStatus, isNew=$isNew');

        if (statut == 'VALIDE') {
          notifications.add({
            'id': 'mentoring_$id',
            'type': 'mentoring_accepte',
            'titre': 'Demande acceptée 🎉',
            'message': 'Votre demande de mentorat avec $nomMentor a été acceptée !',
            'date': dateDebut ?? DateTime.now().toIso8601String(),
            'isNew': isNew,
            'mentoringId': id,
            'statut': statut,
            'mentorName': nomMentor,
          });
        } else if (statut == 'REFUSE') {
          notifications.add({
            'id': 'mentoring_$id',
            'type': 'mentoring_refuse',
            'titre': 'Demande refusée',
            'message': 'Votre demande de mentorat avec $nomMentor a été refusée.',
            'date': dateDebut ?? DateTime.now().toIso8601String(),
            'isNew': isNew,
            'mentoringId': id,
            'statut': statut,
            'mentorName': nomMentor,
          });
        } else if (statut == 'EN_ATTENTE') {
          notifications.add({
            'id': 'mentoring_$id',
            'type': 'mentoring_en_attente',
            'titre': 'Demande en attente',
            'message': 'Votre demande de mentorat avec $nomMentor est en attente de réponse.',
            'date': dateDebut ?? DateTime.now().toIso8601String(),
            'isNew': isNew,
            'mentoringId': id,
            'statut': statut,
            'mentorName': nomMentor,
          });
        }
      }

      // Trier par date (plus récentes en premier)
      notifications.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      return notifications;
    } catch (e) {
      print('❌ Erreur récupération notifications: $e');
      return [];
    }
  }

  /// Compter les nouvelles notifications
  Future<int> countNewNotifications() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n['isNew'] == true).length;
  }

  /// Marquer toutes les notifications comme vues
  Future<void> markAllAsSeen() async {
    try {
      final me = await _profile.getMe();
      final jeuneId = me['id'] as int;
      final mentorings = await _mentorings.getJeuneMentorings(jeuneId);

      final Map<String, String> seen = {};
      for (var m in mentorings) {
        final id = m['id'];
        final statut = m['statut'] ?? m['etat'] ?? 'EN_ATTENTE';
        seen['$id'] = statut;
      }

      await _storage.storage.write(key: _notifKey, value: jsonEncode(seen));
      print('✅ Notifications marquées comme vues');
    } catch (e) {
      print('❌ Erreur marquage notifications: $e');
    }
  }

  /// Récupérer les derniers statuts vus
  Future<Map<String, String>> _getLastSeenMentorings() async {
    try {
      final data = await _storage.storage.read(key: _notifKey);
      if (data != null) {
        final Map<String, dynamic> decoded = jsonDecode(data);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      print('Pas de notifications précédentes');
    }
    return {};
  }
}

