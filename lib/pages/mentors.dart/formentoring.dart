// Fichier: models.dart (Suite)
import 'package:flutter/material.dart';

// Constantes de Style
const Color kPrimaryColor = Color(0xFF3EB2FF); // Le bleu #3EB2FF
const Color kGreenTagColor = Color(0xFF4CAF50); // Vert/Kaki clair pour les tags (simulé)

class MentorPrecedent {
  final String nom;
  final String titre;
  final String imagePath;
  final String note;

  MentorPrecedent({
    required this.nom,
    required this.titre,
    required this.imagePath,
    required this.note,
  });
}

// Données statiques pour simuler le backend
final apprenantNom = 'Amadou Diallo';
final formationsCertifiees = [
  'Couture',
  'Vente',
  'Métallurgie',
  'Santé',
  'Mécanique', // Ajout pour tester le Wrap
  'Cuisine',
];

final mentorsPrecedents = [
  MentorPrecedent(
    nom: 'Ousmane Diallo',
    titre: 'Infirmier',
    imagePath: 'assets/mentor_1.png',
    note: '15/20',
  ),
  MentorPrecedent(
    nom: 'Djénéba Haïdara',
    titre: 'Couturière',
    imagePath: 'assets/mentor_2.png',
    note: '15/20',
  ),
  MentorPrecedent(
    nom: 'Fatou Ndiaye',
    titre: 'Comptable',
    imagePath: 'assets/mentor_3.png',
    note: '14/20',
  ),
  MentorPrecedent(
    nom: 'Moussa Cissé',
    titre: 'Menuisier',
    imagePath: 'assets/mentor_4.png',
    note: '16/20',
  ),
];


class ApprenantProfilePage extends StatelessWidget {
  const ApprenantProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Le défilement vertical principal
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. En-tête (Logo, Flèche de retour, Titre)
            _buildHeader(context),

            // 2. Avatar et Nom du Mentoré
            _buildProfileInfo(apprenantNom),

            const SizedBox(height: 30),

            // 3. Formations Certifiées (Utilisation de Wrap pour la responsivité)
            _buildCertificationsSection(formationsCertifiees),

            const SizedBox(height: 30),

            // 4. Déjà mentoré par (Scrollable Horizontal)
            _buildMentorsPrecedents(mentorsPrecedents),

            const SizedBox(height: 100), // Espace pour le bouton
          ],
        ),
      ),
      // Bouton d'action flottant au bas de l'écran (si l'on veut qu'il soit toujours visible)
      // Sinon, on peut le mettre directement dans la Column, mais on le laisse ici pour qu'il soit sticky.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Action "Mentorer"
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Mentorer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets de Construction de Sections ---

  Widget _buildHeader(BuildContext context) {
    // Hauteur pour l'effet de vague et le logo
    const double waveHeight = 150; 
    
    return Stack(
      children: [
        // Vague Bleue
        ClipPath(
          clipper: ProfilePageClipper(), // Utilisation du Clipper de la page précédente
          child: Container(
            height: waveHeight,
            color: kPrimaryColor,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flèche de retour
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                    // Logo RePartir
                    _buildLogoSmall(),
                  ],
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Formations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSmall() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: kPrimaryColor, width: 2),
      ),
      child: Row(
        children: const [
          Icon(Icons.psychology_outlined, color: kPrimaryColor, size: 20),
          SizedBox(width: 4),
          Text(
            'RePartir',
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String nom) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: kPrimaryColor.withValues(alpha:  0.2),
          child: const Icon(Icons.person, size: 45, color: kPrimaryColor),
        ),
        const SizedBox(height: 10),
        Text(
          nom,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationsSection(List<String> certifications) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.school_outlined, color: kPrimaryColor),
              ),
              const SizedBox(width: 10),
              const Text(
                'Formations certifiées',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Utilisation de Wrap pour les tags
          Wrap(
            spacing: 10.0, // Espace horizontal entre les tags
            runSpacing: 10.0, // Espace vertical entre les lignes
            children: certifications.map((cert) => _buildTag(cert)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: kGreenTagColor.withValues(alpha:0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMentorsPrecedents(List<MentorPrecedent> mentors) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.people_alt_outlined, color: kPrimaryColor),
              ),
              const SizedBox(width: 10),
              const Text(
                'Déjà mentoré par',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // ListView Horizontal pour le défilement
          SizedBox(
            height: 150, // Hauteur fixe pour le conteneur du ListView
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                return _buildMentorCard(mentors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(MentorPrecedent mentor) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: const Icon(Icons.person, size: 18, color: kPrimaryColor),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  mentor.nom.split(' ')[0], // Prénom
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            mentor.titre,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          const Text(
            'Note attribuée à l\'apprenant',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mentor.note,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// NOTE : N'oubliez pas d'inclure la classe ProfilePageClipper de la page précédente.
// Si vous l'avez omise, la voici à nouveau :

class ProfilePageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}