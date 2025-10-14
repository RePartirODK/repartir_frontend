import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/mes_formations_page.dart';
import 'package:repartir_frontend/pages/jeuner/chat_list_page.dart';
import 'package:repartir_frontend/pages/jeuner/mentors_list_page.dart';

// Constantes de couleurs pour plus de facilité
const Color kPrimaryBlue = Color(0xFF2196F3); // Couleur bleue mise à jour
const Color kLightGreyBackground = Color(0xFFEEEEEE); // Couleur de fond du Scaffold
const Color kLogoBlue = Color(0xFF00BFFF); // Bleu clair pour la flèche du logo
const Color kLogoGreen = Color(0xFF4CAF50); // Vert pour l'icône dans le logo

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  int _selectedIndex = 0;

  // Liste des pages à afficher
  static final List<Widget> _pages = <Widget>[
    const _HomePageContent(), // Page d'accueil originale
    const MentorsListPage(), // Page des mentors
    const ChatListPage(),
    const Center(child: Text('Formations')), // Placeholder
    const Center(child: Text('Profil')), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- 6. Barre de navigation inférieure (Standard) ---
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 5,
      selectedItemColor: kPrimaryBlue,
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
          icon: Icon(Icons.people_outline), // Icône mise à jour
          label: 'Mentors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined), // Icône mise à jour
          label: 'Formations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), // Icône mise à jour
          label: 'Profil',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Le Scaffold principal gère la navigation
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigation(),
      body: _pages.elementAt(_selectedIndex),
    );
  }
}

// Widget séparé pour le contenu de la page d'accueil originale
class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Arrière-plan de la page, par défaut en blanc pour éviter les bandes grises
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
        Padding(
          padding: const EdgeInsets.only(top: 120.0), // Décale le début de la carte blanche
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildRecommended(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Contenu de l'en-tête ---
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

  // --- Actions Rapides ---
  Widget _buildQuickActions(BuildContext context) {
    double buttonWidth = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;
    double iconSize = 40;
    double iconProtrusion = 20;

    List<Map<String, dynamic>> actions = [
      {'icon': Icons.grid_view_sharp, 'title': 'Centre de formation'},
      {'icon': Icons.apartment_sharp, 'title': 'Mes parcours'},
      {'icon': Icons.cached, 'title': 'Offres d\'emploi'},
      {'icon': Icons.track_changes_sharp, 'title': 'Kabakoo Academies'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16), // Espace réduit
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: buttonWidth / 130,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MesFormationsPage()),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          actions[index]['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -iconProtrusion,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: iconSize + 10,
                      height: iconSize + 10,
                      decoration: const BoxDecoration(
                        color: kPrimaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          actions[index]['icon'],
                          color: Colors.white,
                          size: iconSize * 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // --- Recommandations ---
  Widget _buildRecommended() {
    final Widget repartirLogoPlaceholder = Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset(
          'assets/images/logo_repartir.png',
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.business, color: kPrimaryBlue, size: 15);
          },
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommandé pour toi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16), // Espace ajusté
        Row(
          children: [
            _buildRecommendedCard(
              repartirLogoPlaceholder,
              'Orange Digital Center',
              kPrimaryBlue,
            ),
            const SizedBox(width: 12),
            _buildRecommendedCard(
              repartirLogoPlaceholder,
              'Kabakoo Academies',
              kPrimaryBlue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendedCard(Widget logo, String title, Color color) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                logo,
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

