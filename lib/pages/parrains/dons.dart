import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/pages/parrains/detailsdemande.dart';
import 'package:repartir_frontend/services/formations_service.dart';
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
  final FormationsService _formationsService = FormationsService();
  final _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _pending = [];
  final Map<int, Map<String, dynamic>> _jeunesById = {};
  final Map<int, ResponseFormation> _formationsById = {};
  List<Map<String, dynamic>> _filtered = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      await _hydrateFormations(demandes);

      setState(() {
        _pending = demandes;
        _loading = false;
        _filtered = List<Map<String, dynamic>>.from(demandes);
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

  Future<void> _hydrateFormations(List<Map<String, dynamic>> demandes) async {
    try {
      // collect unique formation IDs from pending requests
      final ids = <int>{};
      for (final p in _pending) {
        final idFormation = _asInt(p['idFormation']);
        if (idFormation != 0) ids.add(idFormation);
      }
      // fetch each formation detail
      for (final id in ids) {
        final f = await _formationsService.details(id);
        final rf = ResponseFormation.fromJson(f);
        _formationsById[id] = rf;
      }
    } catch (_) {
      // leave map empty; UI will fallback to "Formation #id"
    }
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
                        final utilisateur =
                            jeune['utilisateur'] as Map<String, dynamic>? ?? {};
                        final prenom = (jeune['prenom'] ?? '').toString();
                        final nom = (utilisateur['nom'] ?? '').toString();
                        final name = (prenom.isNotEmpty || nom.isNotEmpty)
                            ? '$prenom $nom'.trim()
                            : 'Jeune #$idJeune';
                        debugPrint(
                          "l'id de la formation $idFormation",
                        ); // Affiche l'id de la formation dans le log
                        final formationTitle = _getFormationTitle(idFormation);
                        final description =
                            'Souhaite être parrainé pour: $formationTitle';
                        return _buildDonationItem(
                          name: name,
                          description: description,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  idJeune: idJeune,
                                  idFormation: idFormation,
                                  idParrainage: _asInt(p['id']),
                                ),
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
  String _getFormationTitle(int idFormation) {
    final f = _formationsById[idFormation];
    if (f != null && f.titre.isNotEmpty) {
      return f.titre;
    }
    // Trigger background fetch and update when ready
    _fetchFormationIfNeeded(idFormation);
    return 'Formation #$idFormation';
  }

  Future<void> _fetchFormationIfNeeded(int id) async {
    if (id == 0 || _formationsById.containsKey(id)) return;
    try {
      final json = await _formationsService.details(id);
      final rf = ResponseFormation.fromJson(json);
      if (mounted) {
        setState(() {
          _formationsById[id] = rf;
        });
      }
    } catch (_) {
      // Silent fail; fallback title remains
    }
  }

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
      child: TextField(
        controller: _searchController,
        onChanged: _applyFilter,
        decoration: const InputDecoration(
          hintText: 'Rechercher ...',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  void _applyFilter(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = List<Map<String, dynamic>>.from(_pending);
        return;
      }
      _filtered = _pending.where((p) {
        final idJeune = _asInt(p['idJeune']);
        final jeune = _jeunesById[idJeune] ?? {};
        final utilisateur = jeune['utilisateur'] as Map<String, dynamic>? ?? {};
        final prenom = (jeune['prenom'] ?? '').toString().toLowerCase();
        final nom = (utilisateur['nom'] ?? '').toString().toLowerCase();
        final name = ('$prenom $nom').trim();

        final idFormation = _asInt(p['idFormation']);
        final formationTitle = _getFormationTitle(idFormation).toLowerCase();

        return name.contains(query) || formationTitle.contains(query);
      }).toList();
    });
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
