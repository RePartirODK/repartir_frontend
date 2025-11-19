// formations_page.dart

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/mentors/custom.dart';
// Importation des widgets personnalisés et des couleurs

// Modèle de données statique pour l'apprenant (facile à remplacer par une API)
class Apprenant {
  final String nom;
  final String statut;

  Apprenant(this.nom, this.statut);
}

class FormationsMentorPage extends StatefulWidget {
  const FormationsMentorPage({super.key});

  @override
  State<FormationsMentorPage> createState() => _FormationsPageState();
}

class _FormationsPageState extends State<FormationsMentorPage> {
 

  // Données statiques pour la liste (sera remplacé par les données du backend)
  final List<Apprenant> apprenants = [
    Apprenant('Amadou Diallo', 'En cours'),
    Apprenant('Ibrahim Diallo', 'En cours'),
    Apprenant('Aisha Konaté', 'En cours'),
    Apprenant('Moussa Traoré', 'Terminé'),
  ];

  @override
  Widget build(BuildContext context) {
    // Media Query pour la responsivité (taille de l'écran)
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 1. HEADER (L'AppBar bleu incurvé)

      // 2. CORPS DE LA PAGE
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomHeader(
              title: "Formations",
              showBackButton: true,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  // Titre de la formation
                  Text(
                    'Mecanique',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize:
                          screenWidth * 0.08, // Très visible et responsive
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Description de la formation (responsive)
                  Text(
                    'Plusieurs niveaux de formation sont disponibles, allant du CAP Maintenance des véhicules pour une entrée rapide dans le métier à des cursus plus longs comme les Bac Pro, BTS, Licences professionnelles, pour une expertise pointue.',
                    style: TextStyle(
                      fontSize:
                          screenWidth *
                          0.038, // Taille du texte adaptée à la largeur
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 25),
                  // En-tête de la liste des apprenants
                  const Row(
                    children: <Widget>[
                      Icon(Icons.group, color: primaryBlue, size: 24),
                      SizedBox(width: 5),
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
                  const SizedBox(height: 1),
                  // La liste des apprenants (utilise ListView.builder pour une intégration facile)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: apprenants.length,
                    itemBuilder: (context, index) {
                      final apprenant = apprenants[index];
                      return ApprenantTile(apprenant: apprenant);
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ), // Espace en bas pour éviter que le contenu touche la nav bar
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
        // Avatar (Style pour imiter l'image fournie)
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryBlue.withValues(alpha:0.1),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          apprenant.statut,
          style: const TextStyle(color: Colors.grey),
        ),
        // Flèche de navigation
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () {
          // Logique pour naviguer vers le détail de l'apprenant
        },
      ),
    );
  }
}
