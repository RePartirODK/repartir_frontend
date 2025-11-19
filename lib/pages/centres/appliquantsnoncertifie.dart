import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/models/response/response_inscription.dart';
import 'package:repartir_frontend/pages/centres/voirappliquant.dart';
import 'package:repartir_frontend/services/centre_service.dart';

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
  const ApplicantsFormationNonTerminePage({super.key,
  required this.formation});
  final ResponseFormation formation;

  @override
  // ignore: library_private_types_in_public_api
  _ApplicantsFormationNonTerminePageState createState() =>
      _ApplicantsFormationNonTerminePageState();
}

class _ApplicantsFormationNonTerminePageState
    extends State<ApplicantsFormationNonTerminePage> {

        final _centreService = CentreService();
  List<ResponseInscription> _filtered = [];

 @override
  void initState() {
    super.initState();
    // Block page if formation is canceled
    if (widget.formation.statut.toUpperCase() == 'ANNULER') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formation annulée. Page indisponible.')),
        );
        Navigator.pop(context);
      });
      return;
    }
    _loadApplicantsForFormation();
  }

    Future<void> _loadApplicantsForFormation() async {
    try {
      final items = await _centreService.getInscriptionsByFormation(widget.formation.id);
      setState(() {
        _filtered = items;
      });
    } catch (e) {
      debugPrint('Failed to load applicants for formation ${widget.formation.id}: $e');
    }
  }

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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group, color: kSecondary, size: 26),
                        const SizedBox(width: 8),
                        Text(
                          "${_filtered.length} Appliquants",
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: kSecondary, // Couleur verte pour le compteur
                          ),
                        ),
                      ],
                    ),
                  ),

                 // 2.3. Liste des Appliquants
                  if (_filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        "Aucun appliquant trouvé.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  else
                    ..._filtered.map((insc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: _buildApplicantCardFromInscription(insc),
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

 
  Widget _buildApplicantCardFromInscription(ResponseInscription insc) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            // Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: kPrimaryColor.withValues(alpha: 0.15),
              child: const Icon(Icons.person, color: kPrimaryColor, size: 30),
            ),
            const SizedBox(width: 15),

            // Nom et formation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insc.nomJeune,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insc.titreFormation,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Boutons d'action/Statut (Alignés à droite)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 5),
                Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplicantProfilePage(inscription: insc),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                        child: Center(
                          child: Text(
                            'Voir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
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

