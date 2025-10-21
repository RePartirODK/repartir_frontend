import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/parrains/dons.dart';
// Importez le composant de barre de navigation si dans un fichier séparé
// import 'custom_bottom_nav_bar.dart';

// Définition des couleurs
const Color primaryBlue = Color(0xFF2196F3);
const Color primaryGreen = Color(0xFF4CAF50);

class ParrainHomePage extends StatefulWidget {
  const ParrainHomePage({super.key});

  @override
  State<ParrainHomePage> createState() => _ParrainHomePageState();
}

class _ParrainHomePageState extends State<ParrainHomePage> {
  // État pour la barre de navigation inférieure

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Le corps de la page avec SingleChildScrollView pour le défilement
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Zone de Tête (Header) ---
            _buildHeader(context),

            // Padding pour le reste du contenu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- Titre d'accueil et Informations de Profil ---
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Bienvenu parrain',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildProfileSection(),

                  const SizedBox(height: 40),

                  // --- Cartes de Statistiques (Jeunes parrainés et Donations) ---
                  _buildStatsCards(),

                  const SizedBox(height: 40),

                  // --- Section Actions ---
                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bouton Donations
                  _buildActionButton(
                    text: 'Donations',
                    color: primaryBlue.withOpacity(0.2),
                    textColor: Colors.black,
                    onPressed: () {
                     
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bouton Jeunes déjà parrainés
                  _buildActionButton(
                    text: 'Jeunes déjà parrainés',
                    color: primaryBlue.withOpacity(0.2), // Bleu très clair
                    textColor: Colors.black, // Texte en noir
                    onPressed: () {
                      /* Logique de navigation */
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -------------------------------------------
  /// WIDGETS DE COMPOSANTS DÉTAILLÉS
  /// -------------------------------------------

  /// Construit la zone de tête (Header) avec la vague bleue.
  Widget _buildHeader(BuildContext context) {
    return ClipPath(
      // Utilisation d'un Clipper pour la forme de vague
      clipper: CustomShapeClipper(),
      child: Container(
        height: 180, // Hauteur du header
        width: double.infinity,
        color: primaryBlue,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 24.0,
            right: 24.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Logo 'RePartir'
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/repartir_logo.png', // Remplacez par le chemin de votre image de logo
                    height: 50,
                  ),
                ),
              ),
              // Ici, j'ai utilisé un placeholder pour le logo, si vous voulez le recréer
              // un Container avec le texte 'RePartir' stylisé avec la couleur verte.
              // Vous devriez utiliser votre propre asset ou créer un widget plus complexe.
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la section du profil (image, nom, statut).
  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: <Widget>[
          // Placeholder pour l'image de profil
          const CircleAvatar(
            radius: 50,
            backgroundColor: primaryBlue,
            child: Icon(
              Icons.person,
              size: 70,
              color: Colors.white,
            ), // Icône pour l'exemple
            // Ou utilisez un Image.asset ou NetworkImage
            // child: Image.asset('assets/profile_pic.png'),
          ),
          const SizedBox(height: 10),
          // Nom (à remplacer par les données du backend)
          const Text(
            'Ousmane Diallo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // Statut (à remplacer par les données du backend)
          const Text(
            'Parrain depuis 2024',
            style: TextStyle(
              fontSize: 14,
              color: primaryGreen, // Couleur verte spécifiée
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit les cartes de statistiques (Responsif avec Flexible).
  Widget _buildStatsCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Carte Jeunes parrainés
        Flexible(
          child: _buildStatCard(title: 'Jeune parrainés', value: '20'),
        ),
        const SizedBox(width: 16),
        // Carte Donations totales
        Flexible(
          child: _buildStatCard(
            title: 'Donations totales',
            value: '25000 fcfa',
          ),
        ),
      ],
    );
  }

  /// Widget pour une carte de statistique individuelle.
  Widget _buildStatCard({required String title, required String value}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour les boutons d'action.
  Widget _buildActionButton({
    required String text,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width *
          0.9, //90% de la largeur de l’écran
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// CLASSER POUR DESSINER LA VAGUE EN HAUT
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // 1. Commence au coin supérieur gauche (0, 0)
    path.lineTo(0, 0);

    // 2. Descend le long du bord gauche.
    // La courbe commence verticalement un peu avant la hauteur totale du clipper (ex: 80%)
    final double startY = size.height * 0.8;
    path.lineTo(0, startY);

    // 3. Définition de la COURBE CUBIQUE DE BÉZIER (4 points pour un meilleur contrôle)

    // Le premier point de contrôle (pour tirer la courbe vers le bas, créant la 'bosse' à gauche)
    final controlPoint1 = Offset(
      size.width * 0.25,
      size.height * 1.15,
    ); // Notez le 1.15 pour un dip sous le container

    // Le deuxième point de contrôle (pour remonter la courbe de manière douce vers la droite)
    final controlPoint2 = Offset(size.width * 0.75, size.height * 0.55);

    // Le point final de la courbe (où la courbe touche le bord droit)
    final endPoint = Offset(size.width, size.height * 0.65);

    // Ajout de la courbe au chemin
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // 4. Trace le chemin restant vers le coin supérieur droit (size.width, 0)
    path.lineTo(size.width, 0);

    // 5. Ferme le chemin
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
