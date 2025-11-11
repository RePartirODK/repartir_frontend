import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/pages/parrains/detailsdemande.dart';
import 'package:repartir_frontend/services/centres_service.dart';
import 'package:repartir_frontend/services/jeune_service.dart';
import 'package:repartir_frontend/services/parrainages_service.dart';
// Définition des couleurs
const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryGreen = Color(0xFF4CAF50);

// -------------------- PAGE DONATIONS --------------------
class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  final ParrainagesService _parrainagesService = ParrainagesService();
  final JeuneService _jeuneService = JeuneService();
  final CentresService _centresService = CentresService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _pending = [];
  final Map<int, Map<String, dynamic>> _jeunesById = {};
  final Map<int, ResponseFormation> _formationsById = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1) Pending parrainage demandes
      final demandes = await _parrainagesService.demandesEnAttente();
      // 2) Jeunes list (for name mapping)
      final jeunes = await _jeuneService.listAll();
      for (final j in jeunes) {
        final id = _asInt(j['id']);
        _jeunesById[id] = j;
      }
      // 3) Hydrate formations (title mapping)
      final centresJson = await _centresService.listActifs();
      for (final c in centresJson) {
        final idCentre =
            c['id'] is int ? c['id'] as int : int.tryParse(c['id']?.toString() ?? '') ?? 0;
        if (idCentre == 0) continue;
       final formations = await _centresService.getFormationsByCentre(idCentre);
       for (final f in formations) {
          final rf = ResponseFormation.fromJson(f);
          _formationsById[rf.id] = rf;
        }
      }
      setState(() {
       _pending = demandes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
 }
   int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _loading
         ? const Center(child: CircularProgressIndicator())
         : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : SingleChildScrollView(
                 child: Column(
                   children: [
             // ---------------- HEADER ----------------
             CustomHeader(title: "Donations"),
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
                  Icon(Icons.favorite, color: primaryGreen, size: 50),
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
                children: _pending.map((p) {
                  final idJeune = _asInt(p['idJeune']);
                  final idFormation = _asInt(p['idFormation']);
                  final jeune = _jeunesById[idJeune] ?? {};
                  final utilisateur = jeune['utilisateur'] as Map<String, dynamic>? ?? {};
                  final prenom = (jeune['prenom'] ?? '').toString();
                  final nom = (utilisateur['nom'] ?? '').toString();
                  final name = (prenom.isNotEmpty || nom.isNotEmpty)
                     ? '$prenom $nom'.trim()
                      : 'Jeune #$idJeune';
                  final formationTitle =
                      _formationsById[idFormation]?.titre ?? 'Formation #$idFormation';
                  final description = 'Souhaite être parrainé pour: $formationTitle';
                  return _buildDonationItem(
                    name: name,
                    description: description,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DetailPage(),
                        ),
                      );
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
                      color: primaryGreen.withValues(
                        alpha: 0.2,
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
