// profil_formation_page.dart

import 'package:flutter/material.dart';
// NOTE: Assurez-vous que le chemin d'importation vers vos composants est correct
// import 'custom_widgets.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/mentors/formationjeune.dart' hide CustomHeader; // Exemple de chemin Header

// Définition de la couleur (assurez-vous que primaryBlue est accessible)
const Color primaryBlue = Color(0xFF3EB2FF);

// Modèle de données statique pour un apprenant (réutilisé de la première page)
class Apprenant {
  final String nom;
  final String statut;

  Apprenant(this.nom, this.statut);
}

class ProfilFormationMentorPage extends StatefulWidget {
  const ProfilFormationMentorPage({super.key});

  @override
  State<ProfilFormationMentorPage> createState() =>
      _ProfilFormationMentorPageState();
}

class _ProfilFormationMentorPageState extends State<ProfilFormationMentorPage> {
  // NOTE: Pas de Bottom NavBar visible sur l'image (3), mais je la commente au cas où.
  // int _selectedIndex = 3; // Index Profil

  // Données statiques pour la liste (sera remplacé par les données du backend)
  final List<Apprenant> apprenants = [
    Apprenant('Amadou Diallo', 'En cours'),
    Apprenant('Ibrahim Diallo', 'En cours'),
    Apprenant('Aisha Konaté', 'Terminé'),
    Apprenant('Moussa Traoré', 'En cours'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 1. HEADER (Le bloc bleu incurvé)

      // 2. CORPS DE LA PAGE
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomHeader(title: "Formation",
            showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10), // Espace sous la vague
                  // Titre de la formation
                  Text(
                    'Mecanique',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description de la formation (responsive)
                  Text(
                    'Plusieurs niveaux de formation sont disponibles, allant du CAP Maintenance des véhicules pour une entrée rapide dans le métier à des cursus plus longs comme les Bac Pro, BTS, Licences professionnelles, pour une expertise pointue.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 25),

                  // En-tête de la liste des apprenants
                  const Row(
                    children: <Widget>[
                      Icon(Icons.group, color: primaryBlue, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Apprenants',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // La liste des apprenants
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: apprenants.length,
                    itemBuilder: (context, index) {
                      final apprenant = apprenants[index];
                      return ApprenantTile(apprenant: apprenant);
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget réutilisable pour chaque élément de la liste
class ApprenantTile extends StatelessWidget {
  final Apprenant apprenant;

  const ApprenantTile({super.key, required this.apprenant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        // Image/Avatar de l'apprenant
        leading: Container(
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
        // Nom et Statut
        title: Text(
          apprenant.nom,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(apprenant.statut),
        // Flèche de navigation
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () {
          // Logique pour naviguer vers le détail de l'apprenant
          /**
           * *
           * 
           */
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Formationjeune()),
          );
        },
      ),
    );
  }
}
