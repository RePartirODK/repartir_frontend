import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/parrains/accueilparrain.dart';
import 'package:repartir_frontend/pages/parrains/dons.dart';
import 'package:repartir_frontend/pages/parrains/profil.dart';
import 'package:repartir_frontend/pages/parrains/voirdetailformation.dart';

// Définition des couleurs (doivent correspondre à celles utilisées dans detail_page.dart)
const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryGreen = Color(0xFF4CAF50);
const Color primaryOrange = Color(0xFFFF9800);
const Color primaryRed = Color(0xFFF44336);

// --- MODÈLE DE DONNÉES ---
class Formation {
  final String id;
  final String centerName;
  final String centerLocation;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String link;
  final int placesAvailable;
  final bool needsFunding;

  Formation({
    required this.id,
    required this.centerName,
    required this.centerLocation,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.link,
    required this.placesAvailable,
    required this.needsFunding,
  });
}

// --- COMPOSANTS RÉUTILISABLES (Clipper et NavBar) ---

// 1. CLASSE CLIPPER (pour la forme 'blob' de l'en-tête)

// 2. CustomBottomNavBar (Barre de navigation inférieure)

// --- PAGE PRINCIPALE : FORMATIONS ---
class FormationPage extends StatefulWidget {
  const FormationPage({Key? key}) : super(key: key);

  @override
  State<FormationPage> createState() => _FormationPageState();
}

class _FormationPageState extends State<FormationPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Formation> _formations = [];

  // Contrôleur pour les onglets 'Toutes' et 'Nouvelles'
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFormations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // LOGIQUE FUTURE POUR LE BACKEND : Récupération des formations
  void _fetchFormations() async {
    // Simuler un appel API pour récupérer la liste des formations
    await Future.delayed(const Duration(seconds: 1));

    List<Formation> loadedFormations = [
      Formation(
        id: 'f1',
        centerName: 'ODC_MALI',
        centerLocation: 'Bamako, Mali',
        title: 'Formation Développeur Web',
        description:
            'Apprenez les bases du développement web avec HTML, CSS et JavaScript',
        startDate: '15 Sept 2023',
        endDate: '15 Mars 2024',
        link: 'www.formation-dev.com/web',
        placesAvailable: 5,
        needsFunding: true,
      ),
      Formation(
        id: 'f2',
        centerName: 'Kabakoo Academies',
        centerLocation: 'En ligne / Régional',
        title: 'Design Thinking et Innovation',
        description:
            'Découvrez les méthodes d\'innovation centrées sur l\'utilisateur.',
        startDate: '01 Jan 2024',
        endDate: '30 Juin 2024',
        link: 'www.kabakoo.com',
        placesAvailable: 12,
        needsFunding: false,
      ),
      // Ajouter une autre formation pour un défilement visible
      Formation(
        id: 'f3',
        centerName: 'ODC_MALI',
        centerLocation: 'Bamako, Mali',
        title: 'Initiation à la Data Science',
        description:
            'Premiers pas dans l\'analyse de données avec Python et R.',
        startDate: '01 Oct 2024',
        endDate: '01 Avr 2025',
        link: 'www.odc-data.com',
        placesAvailable: 3,
        needsFunding: true,
      ),
    ];

    if (mounted) {
      setState(() {
        _formations = loadedFormations;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double headerClipperHeight =
        250.0; // Hauteur généreuse pour englober la recherche

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate([
                      // --- 1. En-tête (Structure fixe avec le "blob", titre, recherche et onglets) ---
                      CustomHeader(title: "Formations"),
                      // --- 2. Barre de recherche ---
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: _buildSearchBar(),
                      ),

                      // --- 3. Onglets (Toutes / Nouvelles) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildFilterTabs(),
                      ),
                    ]),
                  ),
                ];
              },
              // --- 2. Contenu Scrollable (Liste des formations) ---
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Onglet 1: Toutes les formations
                  _buildFormationList(_formations),

                  // Onglet 2: Nouvelles formations (simplement les 2 dernières)
                  _buildFormationList(
                    _formations.sublist(
                      _formations.length > 2 ? _formations.length - 2 : 0,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- WIDGETS DE LA STRUCTURE DE LA PAGE ---

  // Barre de Recherche
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher une formation',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }

  // Onglets "Toutes" et "Nouvelles"
  Widget _buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: primaryBlue.withValues(alpha: 0.63),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        dividerColor: Colors.transparent,
        unselectedLabelColor: primaryBlue,
        labelStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Toutes'),
          Tab(text: 'Nouvelles'),
        ],
      ),
    );
  }

  // Liste des formations
  Widget _buildFormationList(List<Formation> list) {
    if (list.isEmpty) {
      return const Center(child: Text('Aucune formation trouvée.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildFormationCard(context, list[index]);
      },
    );
  }

  // Fiche de Formation individuelle
  Widget _buildFormationCard(BuildContext context, Formation formation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo et Nom du Centre
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 20,
                  // Icône temporaire pour le logo ODC
                  child: Text(
                    'ODC',
                    style: TextStyle(
                      color: primaryOrange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formation.centerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          formation.centerLocation,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Titre de la Formation
            Text(
              formation.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              formation.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            // Détails (Dates, Lien, Places, Financement)
            _buildDetailRow(
              Icons.calendar_today,
              'Du ${formation.startDate} au ${formation.endDate}',
            ),
            _buildDetailRow(Icons.link, formation.link, color: primaryBlue),
            _buildDetailRow(
              Icons.person,
              '${formation.placesAvailable} places disponibles',
            ),
            _buildDetailRow(
              Icons.attach_money,
              'Besoin de financement : ${formation.needsFunding ? 'Oui' : 'Non'}',
              color: formation.needsFunding ? primaryRed : primaryGreen,
            ),

            const SizedBox(height: 10),

            // Bouton Voir détails
            // Bouton Voir détails
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormationDetailsPage(),
                    ),
                  );
                },

                label: const Text(
                  'Voir détails',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.black45,
                  backgroundColor: Colors.white, //
                  foregroundColor: primaryBlue, // 🩶 texte et icône blancs
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3, // ou 2 si tu veux un petit effet d'ombre
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ligne de détail avec icône
  Widget _buildDetailRow(
    IconData icon,
    String text, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: color)),
          ),
        ],
      ),
    );
  }
}
