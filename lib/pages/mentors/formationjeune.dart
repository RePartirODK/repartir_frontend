import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';

// ------------------------------------------------------------------
// PLACEHOLDERS POUR VOS COULEURS ET WIDGETS EXTERNES
// Assurez-vous d'avoir les vraies définitions pour ces éléments.
// ------------------------------------------------------------------

// Définitions de base pour l'exemple
const Color primaryBlue = Color(0xFF2196F3);
const Color primaryGreen = Color(0xFF4CAF50);


// ------------------------------------------------------------------
// WIDGET PRINCIPAL : ProfilePage
// ------------------------------------------------------------------

class Formationjeune extends StatelessWidget {
  const Formationjeune({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenu principal avec bordure arrondie
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                  // --- Section Identité ---
                  _buildIdentitySection(),
                  const SizedBox(height: 40),

                  // --- Section Formations ---
                  _buildSectionTitle(
                    title: 'Formations certifiées',
                    icon: Icons.school,
                  ),
                  const SizedBox(height: 10),
                  _buildTrainingTags(),
                  const SizedBox(height: 40),

                  // --- Section Mentors ---
                  _buildSectionTitle(
                    title: 'Déjà mentoré par',
                    icon: Icons.people,
                  ),
                  const SizedBox(height: 20),
                  _buildMentorCards(),
                  const SizedBox(height: 50),

                  // --- Bouton d'Action ---
                  Center(
                    child: _buildActionButton(
                      text: 'Mentorer',
                      color: primaryBlue.withValues(alpha:0.1), // Bleu très clair/grisé
                      textColor: primaryBlue,
                      onPressed: () {
                        // Action de mentorat
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const CustomHeader(
              title: 'Profil',
              showBackButton: true,
              height: 120,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // WIDGETS DE COMPOSANTS DÉTAILLÉS
  // ------------------------------------------------------------------

  Widget _buildIdentitySection() {
    return const Center(
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 60,
            backgroundColor: primaryBlue,
            child: Icon(
              Icons.person, // Icône par défaut pour l'illustration
              size: 80,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Amadou Diallo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required IconData icon}) {
    return Row(
      children: <Widget>[
        Icon(icon, color: primaryBlue, size: 30),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingTags() {
    final List<String> trainings = ['Couture', 'Métallurgie', 'Vente', 'Santé'];

    // Utilisation de Wrap ou de Column/Row imbriquées (Row ici pour simuler la mise en page de l'image)
    return Wrap(
      spacing: 10.0, // Espace horizontal entre les tags
      runSpacing: 10.0, // Espace vertical entre les lignes
      children: trainings.map((tag) => _buildTag(tag)).toList(),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

 // ------------------------------------------------------------------
// WIDGETS DE COMPOSANTS DÉTAILLÉS
// ------------------------------------------------------------------

Widget _buildMentorCards() {
    // Les données des mentors
    final List<Map<String, String>> mentors = [
      {'name': 'Ousmane Diallo', 'job': 'Infirmier', 'note': '15/20'},
      {'name': 'Djeneba Haidara', 'job': 'Couturière', 'note': '15/20'},
      {'name': 'Autre Mentor', 'job': 'Développeur', 'note': '18/20'},
      {'name': 'Dernier Mentor', 'job': 'Designer', 'note': '14/20'},
    ];

    // Horizontal ListView pour les cartes défilantes
    return SizedBox(
      height: 150, // Hauteur fixe nécessaire pour un ListView horizontal
      child: ListView.builder(
        // C'est cette ligne qui rend le défilement horizontal !
        scrollDirection: Axis.horizontal, 
        
        itemCount: mentors.length + 1,
        itemBuilder: (context, index) {
          if (index >= mentors.length) {
            // Ajoute un espace vide pour la visibilité de la dernière carte
            return const SizedBox(width: 120); 
          }
          final mentor = mentors[index];
          return Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: _buildMentorCard(
              name: mentor['name']!,
              job: mentor['job']!,
              note: mentor['note']!,
            ),
          );
        },
      ),
    );
  }
  Widget _buildMentorCard({
    required String name,
    required String job,
    required String note,
  }) {
    return Container(
      width: 180, // Largeur des cartes
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha:0.1), // Fond bleu très clair
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Avatar du mentor
              const CircleAvatar(
                radius: 18,
                backgroundColor: primaryBlue,
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    job,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Note attribuée à l\'apprenant',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          Text(
            note,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250, // Largeur moyenne pour le bouton
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: primaryBlue.withOpacity(0.3)), // Bordure subtile
          ),
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