import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/pages/parrains/voirdetailformation.dart';
import 'package:repartir_frontend/services/centres_service.dart';
import 'package:repartir_frontend/services/formations_service.dart';

// Définition des couleurs (doivent correspondre à celles utilisées dans detail_page.dart)
const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryGreen = Color(0xFF4CAF50);
const Color primaryOrange = Color(0xFFFF9800);
const Color primaryRed = Color(0xFFF44336);

// --- COMPOSANTS RÉUTILISABLES (Clipper et NavBar) ---

// 1. CLASSE CLIPPER (pour la forme 'blob' de l'en-tête)

// 2. CustomBottomNavBar (Barre de navigation inférieure)

// --- PAGE PRINCIPALE : FORMATIONS ---
class FormationPage extends StatefulWidget {
  const FormationPage({super.key});

  @override
  State<FormationPage> createState() => _FormationPageState();
}

class _FormationPageState extends State<FormationPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<ResponseFormation> _formations = [];
  final CentresService _centresService = CentresService();
  final Map<int, ResponseCentre> _centresById = {};
  final Map<int, String?> _centrePhotoUrls = {}; // Map pour stocker les URLs de photos des centres
  final FormationsService _formationService = FormationsService();
  // Contrôleur pour les onglets 'Toutes' et 'Nouvelles'
  late TabController _tabController;
  List<ResponseFormation> _filteredFormations = [];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFormations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // LOGIQUE FUTURE POUR LE BACKEND : Récupération des formations
  void _fetchFormations() async {
    try {
      // 1) Fetch active centres
      final centres = await _centresService.listActifs();
      // 2) Cache centre details for quick lookup
      for (final c in centres) {
        final centre = ResponseCentre.fromJson(c);
        _centresById[centre.id] = centre;
        
        // Extraire l'URL de la photo depuis le JSON (peut être dans urlPhoto ou utilisateur.urlPhoto)
        String? photoUrl;
        if (c['urlPhoto'] != null && (c['urlPhoto'] ?? '').toString().trim().isNotEmpty) {
          photoUrl = (c['urlPhoto'] ?? '').toString().trim();
        } else if (c['utilisateur'] != null && 
                   c['utilisateur']['urlPhoto'] != null && 
                   (c['utilisateur']['urlPhoto'] ?? '').toString().trim().isNotEmpty) {
          photoUrl = (c['utilisateur']['urlPhoto'] ?? '').toString().trim();
        }
        _centrePhotoUrls[centre.id] = photoUrl;
      }
      // 3) Aggregate formations across centres
      final List<ResponseFormation> agg = [];
      for (final c in centres) {
        final idCentre = c['id'] is int
            ? c['id'] as int
            : int.tryParse(c['id']?.toString() ?? '') ?? 0;
        if (idCentre == 0) continue;
        final list = await _formationService.listByCentre(idCentre);
        for (final f in list) {
          agg.add(ResponseFormation.fromJson(f));
        }
      }
      // Filter out cancelled formations
      final nonCancelled = agg.where((f) => (f.statut).toString().trim().toUpperCase() != 'ANNULER').toList();
      
      // Trier par ID décroissant (les plus récentes en premier - ID plus élevé = plus récent)
      nonCancelled.sort((a, b) => b.id.compareTo(a.id));
      
      if (mounted) {
        setState(() {
          _formations = nonCancelled;
          _filteredFormations = List<ResponseFormation>.from(nonCancelled);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _formations = [];
          _filteredFormations = [];
          _isLoading = false;
        });
      }
    }
  }



  Widget _buildFormationList(List<ResponseFormation> list) {
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

  @override
  Widget build(BuildContext context) {
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
                  _buildFormationList(_filteredFormations),
                 
                  // Onglet 2: Nouvelles formations (simplement les 2 dernières)
                   _buildFormationList(
                    _filteredFormations.sublist(
                      _filteredFormations.length > 2 ? _filteredFormations.length - 2 : 0,
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


       child: TextField(
        controller: _searchController,
        onChanged: _applyFilter,
        decoration: const InputDecoration(
          hintText: 'Rechercher une formation',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }

   void _applyFilter(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // Trier par ID décroissant (les plus récentes en premier)
        final sorted = List<ResponseFormation>.from(_formations);
        sorted.sort((a, b) => b.id.compareTo(a.id));
        _filteredFormations = sorted;
        return;
      }
      final filtered = _formations.where((f) {
        final titre = (f.titre).toString().toLowerCase();
        return titre.contains(query);
      }).toList();
      // Trier les résultats filtrés par ID décroissant
      filtered.sort((a, b) => b.id.compareTo(a.id));
      _filteredFormations = filtered;
    });
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

  // Fiche de Formation individuelle
  Widget _buildFormationCard(
    BuildContext context,
    ResponseFormation formation,
  ) {
    final centre = _centresById[formation.idCentre];
    final centreName = centre?.nom ?? 'Centre inconnu';
    final centreLocation = centre?.adresse ?? 'Adresse indisponible';
    final start = formation.dateDebut;
    final end = formation.dateFin;
    final datesLabel =
        'Du ${start.day}/${start.month}/${start.year} au ${end.day}/${end.month}/${end.year}';
    final linkLabel =
        (formation.urlFormation == null || formation.urlFormation!.isEmpty)
        ? 'N/A'
        : formation.urlFormation!;
    final needsFunding = formation.cout > 0;

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
            Row(
              children: [
                ProfileAvatar(
                  photoUrl: centre != null ? _centrePhotoUrls[centre.id] : null,
                  radius: 20,
                  isPerson: false,
                  backgroundColor: Colors.grey[200],
                  iconColor: primaryBlue,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      centreName,
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
                          centreLocation,
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
            Text(
              formation.titre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              formation.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.calendar_today, datesLabel),
            _buildDetailRow(Icons.link, linkLabel, color: primaryBlue),
            _buildDetailRow(
              Icons.person,
              '${formation.nbrePlace} places disponibles',
            ),
            _buildDetailRow(
              Icons.attach_money,
              'Besoin de financement : ${needsFunding ? 'Oui' : 'Non'}',
              color: needsFunding ? primaryRed : primaryGreen,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Récupérer l'URL de la photo du centre depuis notre map
                  final centrePhotoUrl = centre != null ? _centrePhotoUrls[centre.id] : null;
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormationDetailsPage(
                        formation: formation,
                        centre: centre,
                        centrePhotoUrl: centrePhotoUrl, // Passer l'URL de la photo
                      ),
                    ),
                  );
                },
                label: const Text(
                  'Voir détails',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.black45,
                  backgroundColor: Colors.white,
                  foregroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
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
