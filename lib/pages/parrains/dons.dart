import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/parrains/accueilparrain.dart';
import 'package:repartir_frontend/pages/parrains/formationdetails.dart';
import 'package:repartir_frontend/pages/parrains/profil.dart';

// Définition des couleurs
const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryGreen = Color(0xFF4CAF50);

// -------------------- CUSTOM NAVBAR --------------------

// -------------------- CUSTOM CLIPPER --------------------
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);

    final controlPoint1 = Offset(size.width * 0.25, size.height * 1.15);
    final controlPoint2 = Offset(size.width * 0.75, size.height * 0.55);
    final endPoint = Offset(size.width, size.height * 0.65);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// -------------------- PAGE DONATIONS --------------------
class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  int _selectedIndex = 1; // 'Accueil' est sélectionné par défaut
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
   
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParrainHomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DonationsPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormationPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  // Données fictives
  final List<Map<String, String>> donationNeeds = [
    {
      'name': 'Kadiatou Tall',
      'description': 'Souhaite suivre une formation en couture',
    },
    {
      'name': 'Moussa Diallo',
      'description': 'Besoin d\'équipement pour un atelier de menuiserie',
    },
    {
      'name': 'Aïcha Coulibaly',
      'description': 'Recherche une bourse pour des études en informatique',
    },
    {
      'name': 'Ousmane Traoré',
      'description': 'Besoin de fournitures scolaires',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 180.0;

    return Scaffold(
      backgroundColor: Colors.white,
      // bottomNavigationBar: CustomBottomNavBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onItemTapped,
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Stack(
              children: [
                ClipPath(
                  clipper: CustomShapeClipper(),
                  child: Container(height: headerHeight, color: primaryBlue),
                ),
                // Logo (inchangé)
                Positioned(
                  top: 40,
                  left: 20,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.school, size: 30, color: primaryBlue),
                    // TODO: Remplacer par votre logo
                    // child: Image.asset('assets/logo_repartir.png', height: 40),
                  ),
                ),
                // Titre "Donations" descendu
                Positioned(
                  top: 100, // Descendu pour ne pas toucher le logo
                  left: 0,
                  right: 0,
                  child: Center(
                    child: const Text(
                      'Donations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Bouton retour descendu
                Positioned(
                  top: 95, // Descendu pour aligner avec le titre
                  left: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ---------------- MESSAGE ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Ces jeunes ont besoin de votre aide',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  Icon(Icons.favorite, color: primaryGreen, size: 24),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- BARRE DE RECHERCHE ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(),
            ),

            const SizedBox(height: 20),

            // ---------------- LISTE DES JEUNES ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                children: donationNeeds.map((need) {
                  return _buildDonationItem(
                    name: need['name']!,
                    description: need['description']!,
                    onTap: () {
                      debugPrint('Détails pour ${need['name']}');
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 80), // Espace pour la NavBar
          ],
        ),
      ),
    );
  }

  // -------------------- WIDGETS --------------------

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher ...',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDonationItem({
    required String name,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey.withValues(alpha: 0.3),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: primaryBlue,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(
                        0.2,
                      ), // Cercle vert clair semi-transparent
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: primaryGreen, // Couleur visible
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 4), // Petit espace
                  const Text(
                    'Voir plus',
                    style: TextStyle(color: primaryBlue, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
