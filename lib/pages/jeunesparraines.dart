import 'package:flutter/material.dart';

// --- COULEURS ET CONSTANTES GLOBALES ---
const Color primaryBlue = Color(0xFF2196F3); // Couleur principale bleue
const Color primaryGreen = Color(0xFF4CAF50); // Vert pour l'indicateur de succès
const Color lightGreenBackground = Color(0xFFE8F5E9); // Fond vert très clair pour les cartes

// --- 1. CLASSE CLIPPER (pour la forme 'blob' de l'en-tête) ---
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85); // Début du clip sur la gauche
    
    // Courbe cubique pour la forme irrégulière (le "blob" pour l'en-tête)
    final controlPoint1 = Offset(size.width * 0.25, size.height * 1.15); 
    final controlPoint2 = Offset(size.width * 0.75, size.height * 0.55);
    final endPoint = Offset(size.width, size.height * 0.65);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy, 
      controlPoint2.dx, controlPoint2.dy, 
      endPoint.dx, endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- 2. MODÈLE DE DONNÉES (POUR LA SIMULATION) ---
class SponsoredYouth {
  final String name;
  final String formation;
  final bool hasCertificate; // Le nouvel indicateur
  final String avatarAsset; // Asset pour l'avatar (simulé)
  SponsoredYouth(this.name, this.formation, this.hasCertificate, this.avatarAsset);
}


// --- 3. WIDGET PRINCIPAL : SponsoredYouthPage ---
class SponsoredYouthPage extends StatelessWidget {
  SponsoredYouthPage({super.key});

  // Données de simulation avec le nouvel indicateur
  final List<SponsoredYouth> youths = [
    SponsoredYouth('Ousmane Diallo', 'Mécanique', true, 'male'),
    SponsoredYouth('Kadidja Traoré', 'Couture', true, 'female'),
    SponsoredYouth('Mamadou Kane', 'Développement Web', true, 'male'),
    SponsoredYouth('Aïcha Sidibé', 'Hôtellerie', true, 'female'),
    SponsoredYouth('Issa Touré', 'Électricité Bâtiment', true, 'male'),
    SponsoredYouth('Fatou Camara', 'Design Graphique', true, 'female'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. En-tête bleu et barre de titre
          _buildHeader(context),
          
          // 2. Contenu principal (scrollable)
          Positioned.fill(
            top: 230, // Démarre le contenu sous le titre
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 2.1 Message de remerciement ---
                    _buildThanksMessage(),
                    const SizedBox(height: 25),
                    
                    // --- 2.2 Liste des jeunes parrainés ---
                    ...youths.map((youth) => Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: _buildYouthCard(youth),
                    )),
                    
                    const SizedBox(height: 40), // Espace en bas
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // 3. Barre de navigation (simulée ici pour la conformité de l'image)
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // En-tête avec le clipper et le titre
  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: CustomShapeClipper(),
        child: Container(
          height: 250, 
          color: primaryBlue,
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton retour
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context), 
                ),
                // Titre
                Expanded(
                  child: Text(
                    'Jeune parrainés',
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Placeholder pour le logo RePartir (alignement)
                const SizedBox(width: 48), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Message de remerciement et icône de cœur
  Widget _buildThanksMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Un grand merci pour',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                Text(
                  'tous les jeunes parrainés',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
          ),
          // Icône de cœur verte
          Icon(
            Icons.favorite_border, 
            color: primaryGreen, 
            size: 60
          )
        ],
      ),
    );
  }

  // Carte d'un jeune parrainé avec l'indicateur de certificat
  Widget _buildYouthCard(SponsoredYouth youth) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightGreenBackground, // Fond vert clair
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar du jeune (simulé)
          CircleAvatar(
            radius: 30,
            backgroundColor: primaryBlue.withOpacity(0.1),
            child: Icon(
              youth.avatarAsset == 'male' ? Icons.person : Icons.person_3,
              color: primaryBlue.withOpacity(0.8),
              size: 40,
            ),
          ),
          const SizedBox(width: 15),
          
          // Nom et Formation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  youth.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Formation: ${youth.formation}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          
          // Indicateur de Certification (Nouveau)
          if (youth.hasCertificate)
            Tooltip(
              message: 'A obtenu le certificat de fin de formation',
              child: Icon(
                Icons.workspace_premium, // Icône de diplôme/certificat
                color: primaryGreen,
                size: 30,
              ),
            )
          else 
            Tooltip(
              message: 'Formation en cours',
              child: Icon(
                Icons.pending_actions, // Icône d'attente
                color: Colors.orange.shade700,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }

  // Barre de navigation inférieure (simulée)
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: 1, // Parrainage
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Parrainage'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Formations'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
      onTap: (index) {
        // Logique de navigation (simulée)
        print('Naviguer vers l\'index $index');
      },
    );
  }
}


