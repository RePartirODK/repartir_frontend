import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart'; // Pour les constantes de couleur
import 'package:repartir_frontend/pages/entreprise/mes_offres_page.dart';
import 'package:repartir_frontend/pages/entreprise/statistiques_page.dart';
import 'package:repartir_frontend/pages/entreprise/profil_entreprise_page.dart';

// Définition des constantes de couleur si non déjà définies ailleurs (par exemple dans un fichier core/constants.dart)
// const Color kPrimaryBlue = Color(0xFF2196F3); 
// const Color kLightGreyBackground = Color(0xFFEEEEEE);

class AccueilEntreprisePage extends StatefulWidget {
  const AccueilEntreprisePage({super.key});

  @override
  State<AccueilEntreprisePage> createState() => _AccueilEntreprisePageState();
}

class _AccueilEntreprisePageState extends State<AccueilEntreprisePage> {
  int _selectedIndex = 0;
  String _companyName = "TechPartner"; // Placeholder pour le nom de l'entreprise
  String _companyImageUrl = 'https://via.placeholder.com/150'; // Image de profil de l'entreprise

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigation vers les différentes pages
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MesOffresPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilEntreprisePage()),
      );
    }
  }

  // --- Barre de navigation inférieure ---
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 5,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey.shade600,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Offres',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigation(),
      body: Stack(
        children: [
          // Arrière-plan de la page
          Container(color: Colors.white),

          // En-tête bleu
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: kPrimaryBlue,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeaderContent(),
                ],
              ),
            ),
          ),

          // Contenu principal scrollable avec la courbe
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
              child: Column(
                children: [
                  // Section bienvenue sans carte
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenue $_companyName',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(_companyImageUrl),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenu scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actions rapides',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: _buildQuickActionCard(Icons.work_outline, 'Mes offres publiées', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MesOffresPage()),
                              );
                            })),
                            const SizedBox(width: 15),
                            Expanded(child: _buildQuickActionCard(Icons.add_box_outlined, 'Publier une offre', () {})),
                          ],
                        ),
                          const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: _buildQuickActionCard(Icons.bar_chart, 'Statistiques', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StatistiquesPage()),
                            );
                          }),
                        ),
                          const SizedBox(height: 30),
                          const Text(
                            'Offres récentes',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          _buildRecentOfferCard(
                            'Développeur Front-End',
                            '01-10-2023 / 31-10-2023',
                            'assets/images/logo_repartir.png',
                            () {},
                          ),
                          const SizedBox(height: 15),
                          _buildRecentOfferCard(
                            'Développeur Back-End',
                            '15-09-2023 / 15-10-2023',
                            'assets/images/logo_repartir.png',
                            () {},
                          ),
                          const SizedBox(height: 16), // Padding bottom
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Réutilise le contenu de l'en-tête de AccueilPage (à ajuster si nécessaire)
  Widget _buildHeaderContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/logo_repartir.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Stack(
            children: [
              const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 28,
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kLogoGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOfferCard(String title, String dateRange, String logoPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                logoPath,
                height: 50,
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text(
                        dateRange,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onTap,
              child: const Text('Voir détails', style: TextStyle(color: Colors.blue, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

