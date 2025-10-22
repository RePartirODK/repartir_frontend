import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/centres/voirappliquant.dart';

const Color kPrimaryColor = Color(0xFF3EB2FF);
const Color kSecondary = Color(0xFF4CAF50);
const double kHeaderHeight = 200.0;

class Applicant {
  final String name;
  final bool isCertified;
  final Color avatarColor;
  final IconData icon; // Pour simuler différents avatars

  Applicant({
    required this.name,
    this.isCertified = true,
    required this.avatarColor,
    required this.icon,
  });
}

// Données statiques simulées (qui viendront du backend)
final List<Applicant> dummyApplicants = [
  Applicant(
    name: 'Alima Traoré',
    avatarColor: Colors.brown[400]!,
    icon: Icons.person_3_sharp,
  ),
  Applicant(
    name: 'Alima Traoré',
    avatarColor: Colors.brown[400]!,
    icon: Icons.person_3_sharp,
  ),
  Applicant(
    name: 'Bakary Diallo',
    avatarColor: Colors.cyan[600]!,
    icon: Icons.person_4_sharp,
  ),
  Applicant(
    name: 'Dramane Touré',
    avatarColor: Colors.cyan[600]!,
    icon: Icons.person_4_sharp,
  ),
  Applicant(
    name: 'Aïssata Barry',
    avatarColor: Colors.brown[400]!,
    icon: Icons.person_3_sharp,
  ),
];

class ApplicantsFormationNonTerminePage extends StatefulWidget {
  const ApplicantsFormationNonTerminePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ApplicantsFormationNonTerminePageState createState() =>
      _ApplicantsFormationNonTerminePageState();
}

class _ApplicantsFormationNonTerminePageState
    extends State<ApplicantsFormationNonTerminePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Header Incurvé
          CustomHeader(title: "Appliquants", showBackButton: true),

          // 2. Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 2.2. Compteur d'Appliquants
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "5 Appliquants",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kSecondary, // Couleur verte pour le compteur
                      ),
                    ),
                  ),

                  // 2.3. Liste des Appliquants
                  ...dummyApplicants.map((applicant) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: _buildApplicantCard(applicant),
                    );
                  }),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildApplicantCard(Applicant applicant) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            // Avatar de l'applicant
            CircleAvatar(
              radius: 25,
              backgroundColor: applicant.avatarColor.withValues(alpha: 0.8),
              child: Icon(applicant.icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),

            // Nom de l'applicant
            Expanded(
              child: Text(
                applicant.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Boutons d'action/Statut (Alignés à droite)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 5),
                _buildActionButton('Voir', isPrimary: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, {required bool isPrimary}) {
    // Le style des boutons (Certifié et Voir)
    return Container(
      width: 90, // Largeur fixe pour l'alignement
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(5.0),
        // Pour "Certifié", on peut simuler un badge plus voyant
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: kPrimaryColor.withValues(alpha: 0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            /**
             * Navigation vers la page profil de l'appliquant
             */
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ApplicantProfilePage(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

