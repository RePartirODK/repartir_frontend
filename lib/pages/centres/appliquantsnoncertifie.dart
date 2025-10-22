import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/centres/voirappliquant.dart';

const Color kPrimaryColor = Color(0xFF3EB2FF);
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

class _ApplicantsFormationNonTerminePageState extends State<ApplicantsFormationNonTerminePage> {
  // L'index 1 correspond à "Appliquants" dans la BottomNavigationBar
  int _selectedIndex = 1; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Ajoutez ici la logique de navigation vers la page correspondante
      print("Navigating to index: $_selectedIndex");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigationBar(_selectedIndex, _onItemTapped), 
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Header Incurvé
          CurvedHeader(),

          // 2. Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 2.1. Titre et Flèche de Retour
                  _buildTitleSection(context),

                  // 2.2. Compteur d'Appliquants
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "5 Appliquants",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Couleur verte pour le compteur
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

  // --- Widgets de construction des sections ---

  Widget _buildTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () => Navigator.of(context).pop(), // Action de retour
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Appliquants',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Espace pour aligner le titre
          const SizedBox(width: 48), 
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
        color: kPrimaryColor.withValues(alpha:  0.7),
        borderRadius: BorderRadius.circular(5.0),
        // Pour "Certifié", on peut simuler un badge plus voyant
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: kPrimaryColor.withValues(alpha:  0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                )
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
            Navigator.push(context, 
            MaterialPageRoute(builder: (context)=>
            const ApplicantProfilePage()
            )
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

  Widget _buildBottomNavigationBar(int currentIndex, Function(int) onTap) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey[600],
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Appliquants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Formations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------
// --- WIDGETS DU HEADER INCURVÉ (réutilisés) ---

class CurvedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double finalHeaderHeight = kHeaderHeight * 0.9; 

    return Container(
      height: finalHeaderHeight, 
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: BottomWaveClipper(),
            child: Container(
              height: finalHeaderHeight,
              color: kPrimaryColor, 
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, 
            left: 20, 
            child: _LogoWidget(),
          ),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white, 
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_work, color: kPrimaryColor, size: 30), 
            const Text(
              'RePartir',
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7); 

    var firstControlPoint = Offset(size.width / 4, size.height); 
    var firstEndPoint = Offset(size.width / 2, size.height * 0.85); 
    
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 3 / 4, size.height * 0.7);
    var secondEndPoint = Offset(size.width, size.height * 0.8);

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0); 
    path.close(); 
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}