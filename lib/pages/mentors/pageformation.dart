// formations_list_page.dart

import 'package:flutter/material.dart';
// NOTE: Assurez-vous que le chemin d'importation vers vos composants est correct
// import 'custom_widgets.dart'; 
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/mentors/formationdetails.dart'; // Exemple de chemin Header

// Définition de la couleur (assurez-vous que primaryBlue est accessible)
const Color primaryBlue = Color(0xFF3EB2FF); 

// Modèle de données statique pour une formation
class Formation {
  final String organisme;
  final String lieu;
  final String titre;
  final String description;
  final String dates;
  final String lien;
  final int places;
  final String cout;

  Formation({
    required this.organisme,
    required this.lieu,
    required this.titre,
    required this.description,
    required this.dates,
    required this.lien,
    required this.places,
    required this.cout,
  });
}

class FormationsByMentorPage extends StatefulWidget {
  const FormationsByMentorPage({super.key});

  @override
  State<FormationsByMentorPage> createState() => _FormationsByMentorPageState();
}

class _FormationsByMentorPageState extends State<FormationsByMentorPage> {
  // L'index 1 (Mentorés) est sélectionné sur la nav bar selon l'image
 

  // Données statiques (à remplacer par les données du backend)
  final List<Formation> formations = [
    Formation(
      organisme: 'ODC_MALI',
      lieu: 'Bamako, Mali',
      titre: 'Formation Développeur Web',
      description: 'Apprenez les bases du développement web avec HTML, CSS et JavaScript',
      dates: 'Du 15 Sept 2023 au 15 Mars 2024',
      lien: 'www.formation-dev.com/web',
      places: 5,
      cout: '100.000Fcfa',
    ),
    Formation(
      organisme: 'ODC_MALI',
      lieu: 'Bamako, Mali',
      titre: 'Formation Développeur Mobile',
      description: 'Maîtrisez le développement d\'applications mobiles natives avec Flutter et Dart.',
      dates: 'Du 01 Jan 2024 au 01 Juil 2024',
      lien: 'www.formation-mobile.com/app',
      places: 10,
      cout: '150.000Fcfa',
    ),
    // Ajoutez plus de formations ici
  ];

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
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 100),
                child: Column(
                  children: [
            ListView.builder(
               shrinkWrap: true, //le ListView prend juste la place nécessaire
  physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemCount: formations.length,
              itemBuilder: (context, index) {
                final formation = formations[index];
                return FormationTile(formation: formation);
              },
            ),
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
              title: "Formation",
              showBackButton: true,
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget réutilisable pour chaque carte de formation
class FormationTile extends StatelessWidget {
  final Formation formation;

  const FormationTile({super.key, required this.formation});

  // Widget interne pour afficher une ligne d'information avec icône
  Widget _buildInfoRow(IconData icon, String text, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isLink ? primaryBlue : Colors.black87,
                decoration: isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Organisme et Localisation
            Row(
              children: [
                // Logo (Placeholder pour Orange Digital Center)
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.orange, // Couleur ODC
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('ODC', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                // Nom et Lieu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formation.organisme,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          formation.lieu,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),

            // Titre de la formation
            Text(
              formation.titre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              formation.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 15),

            // Informations Factuelles
            _buildInfoRow(Icons.calendar_month, formation.dates),
            _buildInfoRow(Icons.link, formation.lien, isLink: true),
            _buildInfoRow(Icons.group, '${formation.places} places disponibles'),
            _buildInfoRow(Icons.attach_money, 'Sommes : ${formation.cout}'),
            
            const SizedBox(height: 20),

            // Bouton "Voir détails"
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Logique pour naviguer vers la page de détail de cette formation
                  
                  Navigator.push(context, 
                  MaterialPageRoute(builder: 
                  (context) => const ProfilFormationMentorPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  elevation: 2,
                ),
                child: const Text('Voir détails', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}