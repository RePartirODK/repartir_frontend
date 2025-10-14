import 'package:flutter/material.dart';

// --- MODÈLE DE DONNÉES POUR UN MENTOR ---
// Utilisé pour passer les informations entre la page de liste et la page de détail.
class Mentor {
  final String name;
  final String specialty;
  final String experience;
  final String imageUrl;
  final String about;

  const Mentor({
    required this.name,
    required this.specialty,
    required this.experience,
    required this.imageUrl,
    required this.about,
  });
}

// --- PAGE DE DÉTAIL D'UN MENTOR ---
class MentorDetailPage extends StatelessWidget {
  final Mentor mentor;

  const MentorDetailPage({super.key, required this.mentor});

  // Affiche un modal de confirmation stylisé
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Demande envoyée',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre demande a bien été envoyée au mentor. Vous recevrez une notification dès qu\'il ou elle aura répondu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(fontSize: 16)),
              onPressed: () {
                // Ferme le dialogue
                Navigator.of(context).pop();
                // Revient à la page précédente (liste des mentors)
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryBlue = Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARTE D'INFORMATION DU MENTOR ---
            _buildMentorInfoCard(kPrimaryBlue),
            const SizedBox(height: 24),

            // --- SECTION "À PROPOS" ---
            const Text(
              'À propos du mentor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              mentor.about,
              style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 24),

            // --- CHAMP "OBJECTIF" ---
            const Text(
              'Objectif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Décrivez votre objectif principal...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // --- CHAMP "DESCRIPTION" ---
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Donnez plus de détails sur votre projet ou vos attentes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      // --- BOUTON DE DEMANDE EN BAS DE PAGE ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _showConfirmationDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Demander à être mentoré par ce mentor',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Widget pour la carte bleue d'information du mentor
  Widget _buildMentorInfoCard(Color color) {
    return Container(
      width: double.infinity, // Occupe toute la largeur
      padding: const EdgeInsets.symmetric(vertical: 24), // Ajustement du padding
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.blue[100], // Placeholder
              // backgroundImage: AssetImage(mentor.imageUrl),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            mentor.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mentor.specialty,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mentor.experience,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
