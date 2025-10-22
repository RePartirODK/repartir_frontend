// Fichier: models.dart (Suite)
import 'package:flutter/material.dart';
// import 'models.dart'; 
// Constantes de Style (réutilisées)
const Color kPrimaryColor = Color(0xFF3EB2FF); // Le bleu #3EB2FF

class Mentore {
  final String nom;

  final String imagePath;

  Mentore({
    required this.nom,
    required this.imagePath,
  });
}

class FormationDetail {
  final String titre;
  final String description;
  final List<Mentore> apprenants; // Utilise la classe Mentore de la première page

  FormationDetail({
    required this.titre,
    required this.description,
    required this.apprenants,
  });
}

// Données statiques pour simuler le backend
final formationMecanique = FormationDetail(
  titre: 'Mécanique',
  description:
      "Plusieurs niveaux de formation sont disponibles, allant du CAP Maintenance des véhicules pour une entrée rapide dans le métier à des cursus plus longs comme les Bac Pro, BTS, Licences professionnelles, pour une expertise pointue.",
  apprenants: [
    Mentore(nom: 'Amadou Diallo', imagePath: 'assets/app_1.png'),
    Mentore(nom: 'Ibrahim Diallo', imagePath: 'assets/app_2.png'),
    Mentore(nom: 'Abdoulaye Keïta', imagePath: 'assets/app_3.png'),
    Mentore(nom: 'Aïssata Traoré', imagePath: 'assets/app_4.png'), // Ajout pour tester le défilement
    Mentore(nom: 'Mamadou Koné', imagePath: 'assets/app_5.png'), 
  ],
);

// Assurez-vous d'avoir ProfilePageClipper ou de l'inclure

class FormationDetailMentorPage extends StatelessWidget {
  final FormationDetail formation;
  
  const FormationDetailMentorPage({super.key, required this.formation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Le défilement vertical principal pour tout le contenu
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. En-tête (Logo, Vague, Titre)
            _buildHeader(context),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Titre et Description de la Formation
                  _buildFormationInfo(formation),
                  
                  const SizedBox(height: 30),

                  // 3. Section des Apprenants
                  _buildApprenantsSection(formation.apprenants),
                ],
              ),
            ),
          ],
        ),
      ),
      // 4. Barre de Navigation Inférieure
      bottomNavigationBar: _buildBottomNavigationBar(1), // '1' pour Mentorés sélectionné
    );
  }

  // --- Widgets de Construction de Sections ---

  Widget _buildHeader(BuildContext context) {
    const double waveHeight = 150;
    
    return Stack(
      children: [
        // Vague Bleue
        ClipPath(
          clipper: ProfilePageClipper(), // Utilisation du Clipper
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
                    // Flèche de retour (simulée pour l'exemple)
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
  
  // Fonction utilitaire pour le logo (réutilisée)
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

  Widget _buildFormationInfo(FormationDetail formation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formation.titre,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          formation.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildApprenantsSection(List<Mentore> apprenants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_alt_outlined, color: kPrimaryColor, size: 28),
            const SizedBox(width: 10),
            Text(
              'Apprenants',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // La liste utilise Column et Map pour être contenue dans le SingleChildScrollView parent.
        // Si la liste était très longue (centaines), on utiliserait ListView.builder dans un ConstrainedBox.
        // Ici, Column est plus simple et suffisant pour une liste modérée.
        ...apprenants.map((apprenant) => _buildApprenantCard(apprenant)).toList(),
      ],
    );
  }

  Widget _buildApprenantCard(Mentore apprenant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: kPrimaryColor.withOpacity(0.2),
            child: const Icon(Icons.person, size: 35, color: kPrimaryColor),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                apprenant.nom,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'En cours',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(), // Pousserait le contenu à gauche si on avait un bouton
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigationBar(int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        // Gérer le changement de page
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          label: 'Mentorés', // Sélectionné ici
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Activité',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mail_outline),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}

// N'oubliez pas d'inclure la classe ProfilePageClipper si elle est dans un fichier séparé
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