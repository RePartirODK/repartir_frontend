import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/parrains/dons.dart';
import 'package:repartir_frontend/pages/parrains/jeunesparraines.dart';
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

  // ignore: non_constant_identifier_names
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
            CustomHeader(
              title: 'Accueil',
              showBackButton: true, // Pas de bouton retour sur la home
            ),

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
                    color: primaryBlue.withValues(alpha: 0.2),
                    textColor: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DonationsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bouton Jeunes déjà parrainés
                  _buildActionButton(
                    text: 'Jeunes déjà parrainés',
                    color: primaryBlue.withValues(
                      alpha: 0.2,
                    ), // Bleu très clair
                    textColor: Colors.black, // Texte en noir
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SponsoredYouthPage(),
                        ),
                      );
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
            color: Colors.grey.withValues(alpha: 0.1),
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
