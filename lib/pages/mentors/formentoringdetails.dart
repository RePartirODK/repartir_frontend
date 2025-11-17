// demande_details_page.dart

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/mentor_service.dart';

// --- Constantes de Style ---
const Color primaryBlue = Color(0xFF3EB2FF); // Bleu foncé
const Color kAccentColor = Color(0xFFB3E5FC); // Bleu clair
const Color kBackgroundColor = Color(0xFFF5F5F5); // Fond légèrement gris

// Modèle pour passer les données à la page (statiques pour l'instant)
class DetailDemande {
  final String nom;
  final String objectif;
  final List<String> formations;

  DetailDemande({
    required this.nom,
    required this.objectif,
    required this.formations,
  });
}

class DemandeDetailsPage extends StatefulWidget {
  final DetailDemande demande;

  const DemandeDetailsPage({super.key, required this.demande});

  @override
  State<DemandeDetailsPage> createState() => _DemandeDetailsPageState();
}

class _DemandeDetailsPageState extends State<DemandeDetailsPage> {
  final MentorService _mentorService = MentorService();
  bool _loading = false;

  // Couleurs spécifiques pour les actions
  final Color acceptColor = const Color(0xFF66BB6A); // Vert
  final Color rejectColor = const Color(0xFFEF9A9A); // Rouge pâle

  Future<void> _accepterDemande(int mentoringId) async {
    setState(() => _loading = true);
    try {
      await _mentorService.accepterMentoring(mentoringId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande acceptée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retour avec succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refuserDemande(int mentoringId) async {
    setState(() => _loading = true);
    try {
      await _mentorService.refuserMentoring(mentoringId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande refusée.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Retour avec succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Largeur de l'écran pour la responsivité
    final screenWidth = MediaQuery.of(context).size.width;

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
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Grande Carte des Détails (Fond bleu clair)
                    Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha:0.1), // Couleur de fond bleu très clair
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Infos Nom et Avatar
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: primaryBlue, width: 3),
                        ),
                        child: const Icon(Icons.person, size: 35, color: Colors.blueGrey),
                      ),
                      const SizedBox(width: 15),
                      // Nom
                      Text(
                        widget.demande.nom,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Objectif (Titre)
                  const Text(
                    'Objectif',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Objectif (Contenu)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      widget.demande.objectif,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Formations Certifiées (Titre)
                  const Text(
                    'Formation Certifié',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Tags de Formations
                  Wrap(
                    spacing: 8.0, // Espace horizontal
                    runSpacing: 8.0, // Espace vertical
                    children: widget.demande.formations.map((formation) {
                      return Chip(
                        label: Text(formation),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),         
            const SizedBox(height: 40),

            // 3. BOUTONS D'ACTION
            // Bouton Accepter
            ElevatedButton(
              onPressed: () {
                // Logique pour accepter la demande (appel API, navigation)
                print('Demande acceptée de ${widget.demande.nom}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: acceptColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.1, 
                right: screenWidth * 0.1),
                child: const Text(
                  'Accepter la demande',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 15),

            // Bouton Refuser
            ElevatedButton(
              onPressed: () {
                // Logique pour refuser la demande
                print('Demande refusée de ${widget.demande.nom}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: rejectColor.withValues(alpha: 0.5),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0, // Moins d'ombre pour un bouton secondaire
              ),
              child: Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.1, 
                right: screenWidth * 0.1),
                child: const Text(
                  'Refuser la demande',
                  style: TextStyle(fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 20), // Espace en bas
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
            child: CustomHeader(
              title: "Mentoring",
              showBackButton: true,
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}