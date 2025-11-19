import 'package:flutter/material.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/pages/jeuner/centre_detail_page.dart';
import 'package:repartir_frontend/pages/jeuner/mes_formations_page.dart';
import 'package:repartir_frontend/pages/jeuner/chat_list_page.dart';
import 'package:repartir_frontend/pages/jeuner/mentors_list_page.dart';
import 'package:repartir_frontend/pages/jeuner/profil_page.dart';
import 'package:repartir_frontend/pages/jeuner/centre_list_page.dart';
import 'package:repartir_frontend/pages/jeuner/offre_list_page.dart';
import 'package:repartir_frontend/pages/jeuner/mes_mentors_page.dart';
import 'package:repartir_frontend/pages/jeuner/all_centres_list_page.dart';
import 'package:repartir_frontend/pages/jeuner/notifications_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/centres_service.dart';
import 'package:repartir_frontend/services/jeune_service.dart';
import 'package:repartir_frontend/services/notifications_service.dart';

// Définition des couleurs primaires de l'application
const Color kPrimaryBlue = Color(0xFF3EB2FF); // Un bleu vif et moderne
const Color kLightGreyBackground = Color(
  0xFFEEEEEE,
); // Un gris clair pour les fonds
const Color kLogoBlue = Color(0xFF3EB2FF); // Bleu pour le logo
const Color kLogoGreen = Color(0xFF4CAF50); // Vert pour le logo

// Constantes de couleurs pour plus de facilité
//
//
//
//
class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  int _selectedIndex = 0;
  final GlobalKey<_HomePageContentState> _homeKey =
      GlobalKey<_HomePageContentState>();

  // Liste des pages à afficher
  List<Widget> get _pages => <Widget>[
    _HomePageContent(key: _homeKey), // Page d'accueil originale
    MentorsListPage(), // Page des mentors
    ChatListPage(),
    CentreListPage(), // Placeholder
    ProfilePage(), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Si on revient à l'accueil, recharger les notifications
    if (index == 0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _homeKey.currentState?._loadNotificationCount();
      });
    }
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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
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
class _HomePageContent extends StatefulWidget {
  const _HomePageContent({Key? key}) : super(key: key);

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  final NotificationsService _notifService = NotificationsService();
  int _notifCount = 0;
  final CentresService _centresService = CentresService();
  final JeuneService _jeuneService = JeuneService();
  List<Map<String, dynamic>> _domaines = [];
  int? _selectedDomaineId;
  String _selectedDomaineLabel = '';
  bool _loadingRecs = false;
  List<Map<String, dynamic>> _recommendedCentres = [];

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
    _loadDomaines();
  }

  @override
  void didUpdateWidget(_HomePageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recharger quand le widget est mis à jour
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    try {
      print('🔄 Rechargement du compteur de notifications...');
      final count = await _notifService.countNewNotifications();
      print('🔔 Nouvelles notifications: $count');
      if (mounted) {
        setState(() {
          _notifCount = count;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement notifications: $e');
    }
  }

  Future<void> _loadDomaines() async {
    try {
      final list = await _jeuneService.getDomaines();
      setState(() {
        _domaines = list;
      });
    } catch (_) {}
  }

  Future<void> _computeRecommendations() async {
    final label = _selectedDomaineLabel.trim().toLowerCase();
    if (_selectedDomaineId == null) return;
    setState(() {
      _loadingRecs = true;
      _recommendedCentres = [];
    });
    try {
      final usersInDomain = await _jeuneService.getUtilisateursByDomaine(
        _selectedDomaineId!,
      );
      final userIds = <int>{};
      for (final u in usersInDomain) {
        final id = (u['utilisateur']?['id'] is int)
            ? u['utilisateur']['id'] as int
            : int.tryParse(u['utilisateur']?['id']?.toString() ?? '') ?? 0;
        if (id != 0) userIds.add(id);
      }
      final centresJson = await _centresService.listActifs();
      final List<Map<String, dynamic>> recs = [];
      for (final c in centresJson) {
        final centreUserId = (c['utilisateur']?['id'] is int)
            ? c['utilisateur']['id'] as int
            : int.tryParse(c['utilisateur']?['id']?.toString() ?? '') ?? 0;
        if (centreUserId != 0 && userIds.contains(centreUserId)) {
          recs.add(c);
        }
      }
      // Fallback: keyword match in formations if none found via association
      if (recs.isEmpty) {
        final label = _selectedDomaineLabel.trim().toLowerCase();
        if (label.isNotEmpty) {
          for (final c in centresJson) {
            final idCentre = c['id'] is int
                ? c['id'] as int
                : int.tryParse(c['id']?.toString() ?? '') ?? 0;
            if (idCentre == 0) continue;
            final formations = await _centresService.getFormationsByCentre(
              idCentre,
            );
            final match = formations.any((fjson) {
              final f = ResponseFormation.fromJson(fjson);
              final t = f.titre.toLowerCase();
              final d = f.description.toLowerCase();
              return t.contains(label) || d.contains(label);
            });
            if (match) recs.add(c as Map<String, dynamic>);
          }
        }
      }

      if (mounted) {
        setState(() {
          _recommendedCentres = recs;
          _loadingRecs = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingRecs = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Arrière-plan de la page, par défaut en blanc pour éviter les bandes grises
        Container(color: Colors.white),

        // Contenu principal scrollable avec la courbe
        Positioned(
          top: 160,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSloganCard(),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildRecommended(),
                ],
              ),
            ),
          ),
        ),

        // Header avec logo à gauche et notification à droite
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: CustomHeader(
            leftWidget: _buildLogo(),
            rightWidget: _buildNotificationIcon(),
            height: 160,
          ),
        ),
      ],
    );
  }

  // --- Slogan Card ---
  Widget _buildSloganCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3EB2FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3EB2FF).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF3EB2FF),
            size: 40,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Donnez un nouvel élan à votre carrière.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logo à gauche ---
  Widget _buildLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
    );
  }

  // --- Icône de notification ---
  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: () async {
        // Naviguer vers la page de notifications
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsPage()),
        );
        // Recharger le compteur après retour
        _loadNotificationCount();
      },
      child: Stack(
        children: [
          const Icon(Icons.notifications_none, color: Colors.white, size: 28),
          if (_notifCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  _notifCount > 9 ? '9+' : '$_notifCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
      {'icon': Icons.people, 'title': 'Mes Mentors'},
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
                        color: Colors.grey.withValues(alpha: 0.15),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      // Gérer le clic sur les actions rapides
                      if (index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllCentresListPage(),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MesFormationsPage(),
                          ),
                        );
                      } else if (index == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OffreListPage(),
                          ),
                        );
                      } else if (index == 3) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MesMentorsPage(),
                          ),
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
        // Domaine selection chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _domaines.map((d) {
              final id = d['id'] is int
                  ? d['id'] as int
                  : int.tryParse(d['id']?.toString() ?? '') ?? 0;
              final libelle = (d['libelle'] ?? '').toString();
              final selected = _selectedDomaineId == id;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(libelle),
                  selected: selected,
                  selectedColor: kPrimaryBlue.withOpacity(0.15),
                  onSelected: (val) {
                    setState(() {
                      _selectedDomaineId = val ? id : null;
                      _selectedDomaineLabel = val ? libelle : '';
                    });
                    if (val) _computeRecommendations();
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedDomaineId == null)
          const Text(
            'Choisissez un domaine pour voir des centres recommandés.',
            style: TextStyle(color: Colors.black54),
          )
        else if (_loadingRecs)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: CircularProgressIndicator(color: kPrimaryBlue),
            ),
          )
        else if (_recommendedCentres.isEmpty)
          const Text(
            'Aucun centre correspondant au domaine sélectionné.',
            style: TextStyle(color: Colors.black54),
          )
        else
          Column(
            children: _recommendedCentres.map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildCentreRecommendedCard(c),
              );
            }).toList(),
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

  Widget _buildCentreRecommendedCard(Map<String, dynamic> centreJson) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: kPrimaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          final idCentre = centreJson['id'] is int
              ? centreJson['id'] as int
              : int.tryParse(centreJson['id']?.toString() ?? '') ?? 0;
          if (idCentre != 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CentreDetailPage(centreId: idCentre),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business,
                  color: kPrimaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (centreJson['nom'] ??
                          (centreJson['utilisateur']?['nom'] ?? 'Centre'))
                      .toString(),
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
    );
  }
}
