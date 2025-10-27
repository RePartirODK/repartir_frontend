// demande_details_page.dart

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';

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
  

  // Couleurs spécifiques pour les actions
  final Color acceptColor = const Color(0xFF66BB6A); // Vert
  final Color rejectColor = const Color(0xFFEF9A9A); // Rouge pâle

  @override
  Widget build(BuildContext context) {
    // Largeur de l'écran pour la responsivité
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
     
      // 2. CORPS DE LA PAGE
      body: SingleChildScrollView(
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Grande Carte des Détails (Fond bleu clair)
            CustomHeader(
              title: "Mentoring",
              showBackButton: true,
            ),
            Padding(padding:const EdgeInsets.all(20),
              child: Column(
                children: [
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
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: primaryBlue, width: 3),
                        ),
                        child: const Icon(Icons.person, size: 40, color: Colors.blueGrey),
                      ),
                      const SizedBox(width: 15),
                      // Nom
                      Text(
                        widget.demande.nom,
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Objectif (Titre)
                  Text(
                    'Objectif',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue.withValues(alpha:0.8),
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
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Formations Certifiées (Titre)
                  Text(
                    'Formation Certifié',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue.withValues(alpha:0.8),
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
       
          ],
        ),
      ),
      
      
    );
  }
}