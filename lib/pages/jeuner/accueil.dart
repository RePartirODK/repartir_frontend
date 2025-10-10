import 'package:flutter/material.dart';

// Constantes de couleurs pour plus de facilité
const Color kPrimaryBlue = Color(0xFF007BFF); // Un bleu vif similaire à l'image
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

  // Icons qui se rapprochent le plus de l'image
  final IconData _iconFormation = Icons.grid_view_sharp;
  final IconData _iconParcours = Icons.apartment_sharp;
  final IconData _iconEmploi = Icons.cached;
  final IconData _iconKabakoo = Icons.track_changes_sharp;

  // --- 2. En-tête (Logo et Notification) - ADAPTÉ À LA NOUVELLE IMAGE ---
  Widget _buildHeaderContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo RePartir (Utilise maintenant Image.asset)
          Row(
            children: [
              Container(
                width: 150, // Largeur augmentée pour contenir le texte
                height: 50,
                child: Row(
                  children: [
                    // --- REMPLACEMENT DU LOGO IMAGE D'ASSET ---
                    Container(
                      // Conteneur pour s'assurer que l'image est bien dimensionnée (50x50)
                      width: 60,
                      height: 70,
                      decoration: BoxDecoration(
                        // Décoration retirée pour ne laisser que l'image
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          // Ajout d'une petite ombre pour le relief, si l'image le permet
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'assets/images/logo_repartir.png',
                          fit: BoxFit.cover, // S'assure que l'image couvre le conteneur
                          // S'il y a un problème de chargement, vous pouvez ajouter un placeholder ici
                        ),
                      ),
                    ),
                    // --- FIN DU REMPLACEMENT ---

                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Icône notifications avec point vert
          Stack(
            children: [
              const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 28,
              ),
              // Point vert de notification
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kLogoGreen, // Vert
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

  // --- 4. Section des actions rapides avec grille 2x2 ---
  Widget _buildQuickActions(BuildContext context) {
    // Calcul de la taille de l'icône pour la placer correctement
    double buttonWidth = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;
    double iconSize = 40;
    double iconProtrusion = 20;

    List<Map<String, dynamic>> actions = [
      {'icon': _iconFormation, 'title': 'Centre de formation'},
      {'icon': _iconParcours, 'title': 'Mes parcours'},
      {'icon': _iconEmploi, 'title': 'Offres d\'emploi'},
      {'icon': _iconKabakoo, 'title': 'Kabakoo Academies'},
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
        // ESPACEMENT AJOUTÉ ICI pour descendre les boutons
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: buttonWidth / 130, // Ajuste le ratio pour la hauteur fixe de 130
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return Stack(
              clipBehavior: Clip.none, // Permet à l'icône de déborder
              children: [
                // Bouton d'action rapide (la carte blanche)
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
                    onTap: () {},
                    borderRadius: BorderRadius.circular(15),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0), // Pour descendre le texte
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
                // Icône en cercle (protrusion)
                Positioned(
                  top: -iconProtrusion, // Fait déborder l'icône
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: iconSize + 10,
                      height: iconSize + 10,
                      decoration: const BoxDecoration(
                        color: kPrimaryBlue, // Le cercle est BLEU
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          actions[index]['icon'],
                          color: Colors.white, // L'icône est BLANCHE
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

  // --- 5. Cartes Recommandées ---
  Widget _buildRecommendedCard(Widget logo, String title, Color color) {
    return Expanded(
      child: Container(
        height: 60,
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
                // Logo/Icone placeholder
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

  Widget _buildRecommended() {
    // Placeholder Orange Digital Center
    final Widget orangeLogo = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.flash_on, color: Colors.orange, size: 20),
      ),
    );

    // Placeholder Kabakoo Academies
    final Widget kabakooLogo = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Center(
        child: Icon(Icons.school_outlined, color: Colors.blue.shade700, size: 20),
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
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRecommendedCard(
              orangeLogo,
              'Orange Digital Center',
              kPrimaryBlue,
            ),
            const SizedBox(width: 12),
            _buildRecommendedCard(
              kabakooLogo,
              'Kabakoo Academies',
              kPrimaryBlue, // Les deux boutons semblent être bleus dans l'image
            ),
          ],
        ),
      ],
    );
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
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_pin),
          label: 'Mentors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_sharp),
          label: 'Formations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profil',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Définir le fond légèrement gris pour l'ensemble du Scaffold
    return Scaffold(
      backgroundColor: kLightGreyBackground,
      bottomNavigationBar: _buildBottomNavigation(),
      body: Column(
        children: [
          // 2. En-tête bleu avec la courbe en bas - HAUTEUR AJUSTÉE
          Container(
            height: 150, // Hauteur ajustée pour le logo
            decoration: const BoxDecoration(
              color: kPrimaryBlue,
              // Pas de radius ici, la courbe est gérée par le fond blanc
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16), // Espace supplémentaire en haut
                  _buildHeaderContent(),
                ],
              ),
            ),
          ),
          // 3. Contenu principal (La carte blanche défilante qui recouvre l'en-tête bleu)
          Expanded(
            child: Transform.translate(
              // Décalage négatif pour remonter le contenu au-dessus du fond bleu
              offset: const Offset(0.0, -30.0),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 40.0, bottom: 20.0), // Padding supérieur important pour l'espace créé par le Transform.translate
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Actions rapides (inclut son propre titre)
                      _buildQuickActions(context),
                      const SizedBox(height: 30),
                      // Section Recommandé pour toi (inclut son propre titre)
                      _buildRecommended(),
                      const SizedBox(height: 30), // Espace en bas de la page
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
