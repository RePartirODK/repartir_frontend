import 'package:flutter/material.dart';
import 'package:repartir_frontend/models/chat_contact.dart';
import 'package:repartir_frontend/pages/jeuner/chat_detail_page.dart';
import 'package:repartir_frontend/pages/jeuner/chat_list_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/services/mentorings_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/api_service.dart';
import 'package:repartir_frontend/pages/jeuner/mentor_actif_detail_page.dart';

class MesMentorsPage extends StatefulWidget {
  const MesMentorsPage({super.key});

  @override
  State<MesMentorsPage> createState() => _MesMentorsPageState();
}

class _MesMentorsPageState extends State<MesMentorsPage> {
  final MentoringsService _mentorings = MentoringsService();
  final ProfileService _profile = ProfileService();
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _mentorsList = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final isConnected = await _api.hasToken();
      if (!isConnected) {
        throw Exception('Vous devez être connecté pour voir vos mentors.');
      }
      
      // Récupérer l'ID du jeune connecté
      final me = await _profile.getMe();
      final jeuneId = me['id'] as int;
      
      print('📋 ID du jeune: $jeuneId');
      
      // Récupérer les mentorings du jeune
      final mentorings = await _mentorings.getJeuneMentorings(jeuneId);
      print('📋 Mentorings récupérés: ${mentorings.length}');
      
      // Filtrer UNIQUEMENT les mentorings VALIDES (acceptés)
      final mentoringsValides = mentorings.where((mentoring) {
        final statut = mentoring['statut'] ?? mentoring['etat'] ?? 'EN_ATTENTE';
        print('📋 Mentoring ${mentoring['id']}: statut=$statut');
        return statut == 'VALIDE';
      }).toList();
      
      print('✅ Mentorings VALIDES: ${mentoringsValides.length}');
      
      // Extraire les informations des mentors depuis les mentorings VALIDES uniquement
      _mentorsList = mentoringsValides.map((mentoring) {
        // Le ResponseMentoring contient directement nomMentor, prenomMentor, etc.
        final nomMentor = mentoring['nomMentor'] ?? '';
        final prenomMentor = mentoring['prenomMentor'] ?? '';
        final fullName = '$prenomMentor $nomMentor'.trim();
        final mentorId = mentoring['idMentor'];
        final specialite = mentoring['specialiteMentor'] ?? '';
        final experience = mentoring['anneesExperienceMentor'] ?? 0;
        final urlPhoto = (mentoring['urlPhotoMentor'] ?? '').toString().trim();
        
        print('📋 Mentor: $fullName (ID: $mentorId, Spé: $specialite, Exp: $experience ans)');
        print('📸 URL Photo Mentor: $urlPhoto');
        
        return {
          'id': mentorId,
          'name': fullName.isNotEmpty ? fullName : 'Mentor',
          'speciality': specialite,
          'avatar': urlPhoto,
          'experience': experience,
          'etat': mentoring['statut'] ?? 'VALIDE',
          'mentoring': mentoring, // Passer tout le mentoring pour les détails
        };
      }).toList();
      
      print('📋 Mentors actifs affichés: ${_mentorsList.length}');
    } catch (e) {
      print('❌ Erreur: $e');
      _error = '$e';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock data for mentors (fallback)
    final mentorsFallback = [
      {
        'name': 'Booba Diallo',
        'speciality': 'Développeur Flutter',
        'avatar': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Amadou Diallo',
        'speciality': 'Designer UX/UI',
        'avatar': 'https://via.placeholder.com/150',
      }
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenu principal
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : RefreshIndicator(
                          onRefresh: _fetch,
                          child: _mentorsList.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      'Aucun mentor en contact',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                                  itemCount: _mentorsList.length,
                itemBuilder: (context, index) {
                                    final mentor = _mentorsList[index];
                                    final name = mentor['name'] ?? 'Mentor';
                                    final speciality = mentor['speciality'] ?? '';
                                    final experience = mentor['experience'] ?? 0;
                                    final avatar = mentor['avatar'] ?? '';
                                    final experienceText = experience > 0 ? '$experience ans d\'expérience' : '';
                                    
                                    // Récupérer la note que le jeune a donnée au mentor
                                    final mentoring = mentor['mentoring'] ?? {};
                                    final noteJeune = mentoring['noteJeune'] ?? 0;
                                    
                  return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: ProfileAvatar(
                              photoUrl: avatar,
                              radius: 30,
                              isPerson: true,
                              backgroundColor: Colors.blue[100],
                              iconColor: Colors.blue,
                            ),
                                        title: Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (speciality.isNotEmpty)
                                              Text(
                                                speciality,
                                                style: TextStyle(color: Colors.grey[700]),
                                              ),
                                            if (experienceText.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                experienceText,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 4),
                                            Text(
                                              'Ma note attribuée: $noteJeune/20',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        isThreeLine: experienceText.isNotEmpty,
                            trailing: IconButton(
                              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF3EB2FF)),
                              onPressed: () {
                                final mentoringId = mentoring['id'] as int;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailPage(
                                      mentoringId: mentoringId,
                                      contactName: name,
                                      contactPhoto: avatar,
                                    ),
                                  ),
                                );
                              },
                            ),
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MentorActifDetailPage(
                                                mentoring: mentor['mentoring'],
                                              ),
                                            ),
                                          );
                                          
                                          // ✅ Recharger les données si changement
                                          if (result == true) {
                                            print('✅ Retour avec changement, rechargement mes mentors...');
                                            await _fetch();
                                          }
                                        },
                          ),
                  );
                },
                                ),
              ),
            ),
          ),
          
          // Header avec bouton retour et titre
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              title: 'Mes Mentors',
             
            ),
          ),
        ],
      ),
    );
  }
}
