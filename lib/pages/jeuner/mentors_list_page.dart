import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/mentor_detail_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/mentors_service.dart';
import 'package:repartir_frontend/services/api_service.dart';

const Color kPrimaryBlue = Color(0xFF3EB2FF);

// --- PAGE D'AFFICHAGE DE LA LISTE DES MENTORS ---
class MentorsListPage extends StatefulWidget {
  MentorsListPage({super.key});

  @override
  State<MentorsListPage> createState() => _MentorsListPageState();
}

class _MentorsListPageState extends State<MentorsListPage> {
  final MentorsService _mentors = MentorsService();
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
      _mentorsList = await _mentors.listAll();
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Données factices pour la liste des mentors (fallback)
  static final List<Mentor> _mentorsFallback = [
    Mentor(
      name: 'Fatoumata Diawara',
      specialty: 'Entrepreneuriat',
      experience: '8 ans d\'expérience',
      imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=FD',
      about: 'Fondatrice de trois startups à succès, Fatoumata accompagne les jeunes entrepreneurs dans leurs premiers pas. Passionnée par l\'innovation sociale, elle partage son expertise en création d\'entreprise et en recherche de financements.',
    ),
    Mentor(
      name: 'Bakary Diallo',
      specialty: 'Numérique',
      experience: '5 ans d\'expérience',
      imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=BD',
      about: 'Expert en transformation digitale, Bakary aide les professionnels à naviguer dans le monde du numérique. Son approche pédagogique rend les concepts complexes accessibles à tous.',
    ),
    Mentor(
      name: 'Djibril Maiga',
      specialty: 'Communication',
      experience: '7 ans d\'expérience',
      imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=DM',
      about: 'Spécialiste en communication stratégique, Djibril a travaillé avec de grandes marques pour façonner leur image. Il offre des conseils précieux sur le branding personnel et la prise de parole en public.',
    ),
    Mentor(
      name: 'Amadou Diallo',
      specialty: 'Finance',
      experience: '10 ans d\'expérience',
      imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=AD',
      about: 'Avec une décennie d\'expérience dans le secteur financier, Amadou est un guide fiable pour tout ce qui concerne l\'investissement, la gestion de patrimoine et la planification financière.',
    ),
    Mentor(
      name: 'Cheick Hamala Simpara',
      specialty: 'Marketing Digital',
      experience: '6 ans d\'expérience',
      imageUrl: 'https://placehold.co/150/EFEFEF/333333?text=CS', // Note: Utilise user5, ajuster si nécessaire
      about: 'Passionné par le marketing en ligne, Cheick maîtrise les stratégies de contenu, le SEO et les campagnes sur les réseaux sociaux pour aider les entreprises à accroître leur visibilité.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                                      'Aucun mentor disponible',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                                  itemCount: _mentorsList.length,
                itemBuilder: (context, index) {
                                    final mentorData = _mentorsList[index];
                                    final mentor = _mapToMentor(mentorData);
                                    final mentorId = mentorData['id'] is int 
                                        ? mentorData['id'] as int 
                                        : (mentorData['id'] is String 
                                            ? int.tryParse(mentorData['id'].toString()) 
                                            : null);
                                    return _buildMentorListTile(
                                      context, 
                                      Mentor(
                                        name: mentor.name,
                                        specialty: mentor.specialty,
                                        experience: mentor.experience,
                                        imageUrl: mentor.imageUrl,
                                        about: mentor.about,
                                        id: mentorId,
                                      ), 
                                      mentorId,
                                    );
                },
                separatorBuilder: (context, index) => const Divider(indent: 80),
                                ),
              ),
            ),
          ),
          
          // Header avec titre (sans bouton retour)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              title: 'Mentors',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }

  Mentor _mapToMentor(Map<String, dynamic> data) {
    // Essayer plusieurs chemins pour récupérer les données
    final u = data['utilisateur'] ?? {};
    
    // Récupérer le prénom et le nom
    final prenom = (u['prenom'] ?? data['prenom'] ?? '').toString().trim();
    final nom = (u['nom'] ?? data['nom'] ?? '').toString().trim();
    final name = prenom.isNotEmpty || nom.isNotEmpty 
        ? '$prenom $nom'.trim() 
        : 'Mentor';
    
    // Récupérer la spécialité
    final specialty = (data['specialite'] ?? data['domaine'] ?? data['profession'] ?? data['speciality'] ?? '—').toString().trim();
    
    // Récupérer l'expérience - essayer plusieurs variantes
    dynamic anneesExp = data['anneesExperience'] ?? 
                       data['anneeExperience'] ?? 
                       data['annees_experience'] ?? 
                       data['annee_experience'] ??
                       data['yearsOfExperience'] ??
                       data['years_of_experience'] ??
                       data['experience'] ??
                       u['anneesExperience'] ??
                       u['anneeExperience'];
    
    // Si c'est une chaîne, essayer de la convertir en nombre
    String experience = '—';
    if (anneesExp != null) {
      if (anneesExp is int || anneesExp is double) {
        experience = '${anneesExp.toString().split('.').first} ans d\'expérience';
      } else if (anneesExp is String) {
        final expNum = int.tryParse(anneesExp);
        if (expNum != null) {
          experience = '$expNum ans d\'expérience';
        } else if (anneesExp.isNotEmpty) {
          // Si c'est déjà une chaîne formatée, l'utiliser directement
          experience = anneesExp;
        }
      }
    }
    
    // Récupérer la photo
    final imageUrl = (u['urlPhoto'] ?? data['urlPhoto'] ?? u['photoUrl'] ?? data['photoUrl'] ?? 'https://placehold.co/150/EFEFEF/333333?text=M').toString();
    
    // Récupérer la description
    final about = (data['description'] ?? data['a_propos'] ?? data['aPropos'] ?? data['about'] ?? u['description'] ?? '').toString().trim();
    
    return Mentor(
      name: name,
      specialty: specialty.isEmpty ? '—' : specialty,
      experience: experience,
      imageUrl: imageUrl,
      about: about.isEmpty ? 'Aucune description disponible' : about,
    );
  }

  // Widget pour un élément de la liste des mentors
  Widget _buildMentorListTile(BuildContext context, Mentor mentor, int? mentorId) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        backgroundImage: mentor.imageUrl.isNotEmpty && 
                        mentor.imageUrl != 'https://placehold.co/150/EFEFEF/333333?text=M'
            ? NetworkImage(mentor.imageUrl)
            : null,
        onBackgroundImageError: mentor.imageUrl.isNotEmpty && 
                               mentor.imageUrl != 'https://placehold.co/150/EFEFEF/333333?text=M'
            ? (_, __) {}
            : null,
        child: mentor.imageUrl.isEmpty || 
               mentor.imageUrl == 'https://placehold.co/150/EFEFEF/333333?text=M'
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
      title: Text(mentor.name.trim().isEmpty ? 'Mentor' : mentor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            mentor.specialty,
            style: const TextStyle(color: Color(0xFF3EB2FF), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(mentor.experience, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF3EB2FF), size: 18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MentorDetailPage(mentor: mentor),
          ),
        );
      },
    );
  }
}
