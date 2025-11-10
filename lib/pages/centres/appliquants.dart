import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/response/response_inscription.dart';
import 'package:repartir_frontend/pages/centres/voirappliquant.dart';
import 'package:repartir_frontend/services/centre_service.dart';

// Définition des constantes et modèles de données
const Color kPrimaryColor = Color(0xFF3EB2FF);
const double kHeaderHeight = 200.0;

class Applicant {
  final String name;
  final Color avatarColor;
  final IconData icon; 

  Applicant({
    required this.name,
    required this.avatarColor,
    required this.icon,
  });
}

// Données statiques simulées
final List<Applicant> dummyApplicants = [
  Applicant(
    name: 'Alima Traoré',
    avatarColor: Colors.brown[400]!,
    icon: Icons.person_3_sharp,
  ),
  Applicant(
    name: 'Moussa Touré',
    avatarColor: Colors.cyan[600]!,
    icon: Icons.person_4_sharp,
  ),
  Applicant(
    name: 'Moussa Touré',
    avatarColor: Colors.cyan[600]!,
    icon: Icons.person_4_sharp,
  ),
  Applicant(
    name: 'Moussa Touré',
    avatarColor: Colors.cyan[600]!,
    icon: Icons.person_4_sharp,
  ),
  Applicant(
    name: 'Aïssata Barry',
    avatarColor: Colors.brown[400]!,
    icon: Icons.person_3_sharp,
  ),
  Applicant(
    name: 'Bakary Diallo',
    avatarColor: Colors.cyan[600]!,
    icon: Icons.person_4_sharp,
  ),
];

// **************************************************
// WIDGET STATEFUL POUR LA PAGE APPLICANTS
// **************************************************

class GeneralApplicantsPage extends StatefulWidget {
  const GeneralApplicantsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GeneralApplicantsPageState createState() => _GeneralApplicantsPageState();
}

class _GeneralApplicantsPageState extends State<GeneralApplicantsPage> {
  // L'index 1 correspond à "Appliquants" dans la BottomNavigationBar
  int _selectedIndex = 1; 
  final TextEditingController _searchController = TextEditingController();
  final _centreService = CentreService();
  List<ResponseInscription> _inscriptions = [];
  List<ResponseInscription> _filtered = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Ajoutez ici la logique de navigation vers la page correspondante
      print("Navigating to index: $_selectedIndex");
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


    Future<void> _loadApplicants() async {
    try {
      final currentCentre = await _centreService.getCurrentCentre();
      final centreId = currentCentre?.id ?? 0;
      if (centreId == 0) {
        debugPrint('Centre ID not found');
        return;
      }
      final items = await _centreService.getCentreInscriptions(centreId);
      setState(() {
        _inscriptions = items;
        _filtered = items;
      });
    } catch (e) {
      debugPrint('Failed to load applicants: $e');
    }
  }

   void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _inscriptions;
      } else {
        _filtered = _inscriptions.where((i) => i.nomJeune.toLowerCase().contains(q)).toList();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Header Incurvé
          CustomHeader(title: "Appliquants"),

          // Contenu scrollable (y compris le titre, la barre de recherche et la liste)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                 

                  // 3. Barre de Recherche
                  _buildSearchBar(),

                  const SizedBox(height: 20),

                  // 4. Liste des Appliquants
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

  // --- Widgets de construction des sections ---



   Widget _buildApplicantCardFromInscription(ResponseInscription insc) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: Colors.blue, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insc.nomJeune,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insc.titreFormation,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            _buildViewButtonWithNav(
              insc
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:  0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // Ombre subtile
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une formation',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none, // Pas de bordure visible
          ),
        ),
        onChanged: (value) {
          // Logique de filtrage de la liste ici
          debugPrint("Searching for: $value");
        },
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

            // Bouton "Voir" (Aligné à droite)
            _buildViewButton('Voir'),
          ],
        ),
      ),
    );
  }

  Widget _buildViewButton(String text) {
    // Le style du bouton "Voir"
    return Container(
      width: 90, // Largeur fixe pour l'alignement
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha:0.7),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            /**
             * Navigation vers la page profil de l'appliquant
             
            Navigator.push(context, 
            MaterialPageRoute(builder: (context)=>
            const ApplicantProfilePage()
            )
            );*/
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
  
  Widget _buildViewButtonWithNav(ResponseInscription insc) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha:0.7),
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
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
    );
  }
  

}

