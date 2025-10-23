// mentores_page.dart

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/mentors.dart/formationviewbymentor.dart';
import 'package:repartir_frontend/pages/mentors.dart/pageformation.dart';
import 'package:repartir_frontend/pages/parrains/formationdetails.dart';

Color primaryBlue = Color(0xFF3EB2FF);

// Modèle de données statique pour un mentoré
class Mentore {
  final String nom;
  final int dureeMois;
  final int scoreActuel;
  final int scoreTotal;

  Mentore(this.nom, this.dureeMois, this.scoreActuel, this.scoreTotal);
}

class MentoresPage extends StatefulWidget {
  const MentoresPage({super.key});

  @override
  State<MentoresPage> createState() => _MentoresPageState();
}

class _MentoresPageState extends State<MentoresPage> {
  // L'index 1 (Mentorés) est sélectionné sur la nav bar selon l'image

  // Données statiques pour la liste (à remplacer par les données de votre backend)
  final List<Mentore> mentores = [
    Mentore('Ramatou Touré', 6, 0, 20),
    Mentore('Ibrahim Diarra', 8, 15, 20),
    Mentore('Aïcha Cissé', 3, 5, 10),
    Mentore('Moussa Kouyaté', 12, 0, 20),
    Mentore('Fatima Sy', 6, 8, 10),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // 2. CORPS DE LA PAGE (Liste des mentorés)
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(title: "Mentorés", showBackButton: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // aligne à droite
                children: [
                  ElevatedButton(
                    onPressed: () {
                      /**
         * Découvrir les formations du système
         */
                      Navigator.push(context,
                      MaterialPageRoute(builder: 
                      (context) => const FormationsByMentorPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 5,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Découvrir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: mentores.length,
                itemBuilder: (context, index) {
                  final mentore = mentores[index];
                  return MentoreTile(mentore: mentore);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget réutilisable pour chaque élément de la liste
class MentoreTile extends StatelessWidget {
  final Mentore mentore;

  const MentoreTile({super.key, required this.mentore});

  @override
  Widget build(BuildContext context) {
    // Déterminer la couleur du score (rouge/orange si 0, sinon gris)
    final scoreColor = mentore.scoreActuel == 0
        ? Colors.red.shade700
        : Colors.blueGrey;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Avatar et Score/Progression
            SizedBox(
              width: 90,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryBlue.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.blueGrey,
                    ), // Placeholder
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${mentore.scoreActuel}/${mentore.scoreTotal}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            ),

            // Nom et Statut
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mentore.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mentoré depuis ${mentore.dureeMois} mois',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bouton "Noter le mentoré" et Indicateur de statut
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bouton Noter
                ElevatedButton(
                  onPressed: () {
                    // Logique pour naviguer vers la page de notation
                    print('Noter ${mentore.nom}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Noter le mentoré',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
                // Indicateur de statut (cercle bleu)
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
