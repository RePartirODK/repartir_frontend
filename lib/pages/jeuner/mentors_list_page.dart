import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/mentor_detail_page.dart';

const Color kPrimaryBlue = Color(0xFF2196F3);

// --- PAGE D'AFFICHAGE DE LA LISTE DES MENTORS ---
class MentorsListPage extends StatelessWidget {
  const MentorsListPage({super.key});

  // Données factices pour la liste des mentors
  static final List<Mentor> _mentors = [
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
    return Stack(
      children: [
        // Arrière-plan de la page
        Container(color: Colors.white),

        // En-tête bleu
        Container(
          height: 160,
          decoration: const BoxDecoration(
            color: kPrimaryBlue,
          ),
        ),

        // Contenu principal scrollable avec la liste
        Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    'Mentors',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _mentors.length,
                    itemBuilder: (context, index) {
                      final mentor = _mentors[index];
                      return _buildMentorListTile(context, mentor);
                    },
                    separatorBuilder: (context, index) => const Divider(indent: 80),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget pour un élément de la liste des mentors
  Widget _buildMentorListTile(BuildContext context, Mentor mentor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(mentor.imageUrl),
      ),
      title: Text(mentor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            mentor.specialty,
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(mentor.experience, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 18),
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
