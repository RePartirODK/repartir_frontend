import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart'; // Pour les constantes de couleur
import 'package:repartir_frontend/pages/entreprise/mes_offres_page.dart';
import 'package:repartir_frontend/pages/entreprise/statistiques_page.dart';
import 'package:repartir_frontend/pages/entreprise/profil_entreprise_page.dart';
import 'package:repartir_frontend/pages/entreprise/detail_offre_page.dart';
import 'package:repartir_frontend/pages/entreprise/nouvelle_offre_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/offre_emploi_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/models/offre_emploi.dart';

class AccueilEntreprisePage extends StatefulWidget {
  const AccueilEntreprisePage({super.key});

  @override
  State<AccueilEntreprisePage> createState() => _AccueilEntreprisePageState();
}

class _AccueilEntreprisePageState extends State<AccueilEntreprisePage> {
  final OffreEmploiService _offreService = OffreEmploiService();
  final ProfileService _profileService = ProfileService();
  
  int _selectedIndex = 0;
  String _companyName = "Entreprise";
  String _companyImageUrl = 'https://via.placeholder.com/150';
  int _nombreOffres = 0;
  bool _isLoading = true;
  List<OffreEmploi> _offresRecentes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getMe();
      final offres = await _offreService.getMesOffres();
      
      // Trier les offres par ID décroissant (les plus récentes en premier) et prendre les 2 dernières
      final offresTriees = List<OffreEmploi>.from(offres)..sort((a, b) => b.id.compareTo(a.id));
      final deuxDernieres = offresTriees.take(2).toList();
      
      setState(() {
        _companyName = profile['nom'] ?? 'Entreprise';
        _companyImageUrl = profile['urlPhotoEntreprise'] ?? '';
        _nombreOffres = offres.length;
        _offresRecentes = deuxDernieres;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur chargement données: $e');
      setState(() => _isLoading = false);
    }
  }

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
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _companyImageUrl.isNotEmpty ? NetworkImage(_companyImageUrl) : null,
                          child: _companyImageUrl.isEmpty
                              ? Icon(Icons.business, size: 30, color: Colors.grey.shade600)
                              : null,
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
                      Expanded(child: _buildQuickActionCard(Icons.add_box_outlined, 'Publier une offre', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NouvelleOffrePage()),
                        );
                      })),
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
                  
                  // Afficher les offres récentes ou un message si aucune offre
                  if (_offresRecentes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.work_off_outlined, size: 50, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune offre publiée',
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._offresRecentes.map((offre) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildRecentOfferCardFromOffre(offre),
                      );
                    }).toList(),
                  
                  const SizedBox(height: 16), // Padding bottom
                ],
                      ),
              ),
            ),
          ],
        ),
            ),
          ),
          
          // En-tête bleu avec forme ondulée (au-dessus du contenu)
          Stack(
            children: [
              CustomHeader(title: 'Accueil'),
              Positioned(
                height: 80,
                width: 80,
                top: 30,
                left: 20,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/images/logo_repartir.png',
                    height: 300,
                    width: 300,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Réutilise le contenu de l'en-tête de AccueilPage (à ajuster si nécessaire)
  Widget _buildHeaderContent() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        // Logo à gauche (avec petit espacement)
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
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
          ),
        ),
        // Notification à droite (avec petit espacement)
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Stack(
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
          ),
        ],
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
              color: Colors.grey.withValues(alpha:0.1),
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
                color: Colors.blue.withValues(alpha: 0.1),
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

  Widget _buildRecentOfferCardFromOffre(OffreEmploi offre) {
    final dateRange = '${DateFormat('dd/MM/yy').format(offre.dateDebut)} - ${DateFormat('dd/MM/yy').format(offre.dateFin)}';
    final isActive = offre.isActive;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailOffrePage(offre: offre.toDetailMap()),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo de l'entreprise
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _companyImageUrl.isNotEmpty ? NetworkImage(_companyImageUrl) : null,
              child: _companyImageUrl.isEmpty
                  ? Icon(Icons.business, size: 25, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offre.titre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text(
                        dateRange,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Badge statut
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.shade100 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Expirée',
                      style: TextStyle(
                        color: isActive ? Colors.green.shade700 : Colors.grey.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

