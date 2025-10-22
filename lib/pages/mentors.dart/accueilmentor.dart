import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';


// --- Constantes de Style ---
const Color kPrimaryColor = Color(0xFF3EB2FF); // Bleu foncé
const Color kAccentColor = Color(0xFFB3E5FC); // Bleu clair
const Color kBackgroundColor = Color(0xFFF5F5F5); // Fond légèrement gris

// --- Widget Principal ---

// Fichier: models.dart

class MentorStat {
  final int mentoring;
  final int demande;
  final int dejaMentores;

  MentorStat({
    required this.mentoring,
    required this.demande,
    required this.dejaMentores,
  });
}

class Mentore {
  final String nom;
  final String imagePath; // Simule un chemin d'image

  Mentore({required this.nom, required this.imagePath});
}

// Données statiques pour simuler le backend
final mentorStats = MentorStat(
  mentoring: 4,
  demande: 5,
  dejaMentores: 5,
);

final mentoringsEnCours = [
  Mentore(nom: 'Amadou Diallo', imagePath: 'assets/mentore_1.png'),
  Mentore(nom: 'Aissata Diakité', imagePath: 'assets/mentore_2.png'),
  Mentore(nom: 'Ismael Touré', imagePath: 'assets/mentore_3.png'),
  // Ajoutez plus d'éléments pour tester le défilement horizontal
  Mentore(nom: 'Fatou Ndiaye', imagePath: 'assets/mentore_4.png'),
  Mentore(nom: 'Moussa Cissokho', imagePath: 'assets/mentore_5.png'),
];

final requeteEnAttente = Mentore(
  nom: 'Abdou Abarchi Ibrahim',
  imagePath: 'assets/mentore_req.png',
);
class MentorHomePage extends StatelessWidget {
  const MentorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Rend la page scrollable verticalement
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. En-tête et Profil
            _buildHeaderAndProfile(context),

            const SizedBox(height: 20),

            // 2. Aperçu des Statistiques
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildStatsApercu(mentorStats),
            ),

            const SizedBox(height: 30),

            // 3. Mentoring en Cours (Scrollable Horizontal)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _buildMentoringEnCours(mentoringsEnCours),
            ),

            const SizedBox(height: 30),

            // 4. Requête en Attente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildRequeteEnAttente(requeteEnAttente),
            ),

            const SizedBox(height: 100), // Espace pour la barre de navigation
          ],
        ),
      ),
  
    );
  }

  // --- Widgets de Construction de Sections ---

  Widget _buildHeaderAndProfile(BuildContext context) {
    // Utilisation d'un Stack pour l'effet de vague bleue en haut
    return Stack(
      alignment: Alignment.topCenter,
      children: [
       CustomHeader(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
            child: Column(
              children: [
                // Logo 'RePartir'
                _buildLogo(),
                const SizedBox(height: 70),
                // Titre et Profil
                const Text(
                  'Bienvenue Mentor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: kAccentColor,
                  child: Image.asset(
                    'assets/mentor_profile.png', // Image de profil du mentor
                    height: 80,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ousmane Diallo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
Widget _buildLogo() {
  return Container(
    alignment: AlignmentGeometry.topLeft,
    height: 100,
    width: 100.0,
    decoration: BoxDecoration(
      color: Colors.white, // 👈 ou kPrimaryColor si ton logo est clair
      borderRadius: BorderRadius.circular(50),
    ),
    child: Image.asset(
      'assets/images/logo_repartir.png',
      height: 100,
    ),
  );
}


  Widget _buildStatsApercu(MentorStat stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aperçu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        // Ligne 1: Mentoring et Demande
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Mentoring', stats.mentoring),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard('Demande', stats.demande),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // Ligne 2: Déjà mentorés
        _buildStatCard('Déjà mentorés', stats.dejaMentores, isLarge: true),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isLarge
          ? Center(
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMentoringEnCours(List<Mentore> mentorings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mentoring en cours',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        // ListView Horizontal pour le défilement horizontal
        SizedBox(
          height: 120, // Hauteur fixe pour le ListView horizontal
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mentorings.length,
            itemBuilder: (context, index) {
              final mentore = mentorings[index];
              return Container(
                width: 100, // Largeur fixe pour chaque élément
                margin: const EdgeInsets.only(right: 15),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: kAccentColor.withValues(alpha: 0.3),
                      // Remplacer par Image.network(mentore.imagePath) en production
                      child: const Icon(Icons.person, size: 40, color: kPrimaryColor), 
                    ),
                    const SizedBox(height: 5),
                    Text(
                      mentore.nom.split(' ')[0], // Affiche seulement le prénom ou le premier mot
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequeteEnAttente(Mentore requete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requête en attente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha:0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: kAccentColor.withValues(alpha:0.3),
                child: const Icon(Icons.person, size: 30, color: kPrimaryColor),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  requete.nom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Action pour voir la requête
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Voir', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

}