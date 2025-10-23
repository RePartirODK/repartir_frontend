// mentoring_page.dart

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/mentors.dart/formentoringdetails.dart';

// --- Constantes de Style ---
const Color primaryBlue = Color(0xFF3EB2FF); // Bleu foncé
const Color kAccentColor = Color(0xFFB3E5FC); // Bleu clair
const Color kBackgroundColor = Color(0xFFF5F5F5); // Fond légèrement gris

// Modèle de données statique pour une demande de mentoring
class DemandeMentoring {
  final String nom;
  // On pourrait ajouter d'autres champs ici, ex: final String formation;

  DemandeMentoring(this.nom);
}

class MentoringPage extends StatefulWidget {
  const MentoringPage({super.key});

  @override
  State<MentoringPage> createState() => _MentoringPageState();
}

class _MentoringPageState extends State<MentoringPage> {
  // 2. DONNÉES STATIQUES (à remplacer par les données de votre backend)
  final List<DemandeMentoring> demandes = [
    DemandeMentoring('Abdou Abarchi Ibrahim'),
    DemandeMentoring('Fatima Zahra Ahmed'),
    DemandeMentoring('Moussa Diallo'),
    DemandeMentoring('Aïcha Konaté'),
    DemandeMentoring('Ibrahim Diop'),
    DemandeMentoring("Aidan Traoré")
    // Ajoutez plus de données ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 4. CORPS DE LA PAGE (Liste des demandes)
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(title: "Mentoring"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: demandes.length,
                itemBuilder: (context, index) {
                  final demande = demandes[index];
                  return DemandeTile(demande: demande);
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
class DemandeTile extends StatelessWidget {
  final DemandeMentoring demande;

  const DemandeTile({super.key, required this.demande});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2, // Légère ombre pour soulever la carte
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
        child: Row(
          children: <Widget>[
            // Avatar (Style pour imiter l'image)
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 15),
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

            // Nom de l'utilisateur
            Expanded(
              child: Text(
                demande.nom,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),

            // Bouton "Voir"
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: ElevatedButton(
                onPressed: () {
                  // Logique de navigation vers la page de détail de la demande
                  /**
                   * On navigue vers la page qui affiche les détals de la démande
                   */
                  final detail = DetailDemande(
                    nom: demande.nom,
                    objectif: "Devenir expert en leadership et mentorat",
                    formations: [
                      "Communication",
                      "Coaching",
                      "Développement personnel",
                    ],
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DemandeDetailsPage(demande: detail),
                    ),
                  );
                
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  elevation: 0,
                ),
                child: const Text('Voir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
