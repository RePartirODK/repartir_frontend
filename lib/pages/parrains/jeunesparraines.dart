import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/services/centres_service.dart';
import 'package:repartir_frontend/services/parrainages_service.dart';

// --- COULEURS ET CONSTANTES GLOBALES ---
const Color primaryBlue = Color(0xFF3EB2FF); // Couleur principale bleue
const Color primaryGreen = Color(
  0xFF4CAF50,
); // Vert pour l'indicateur de succès
const Color lightGreenBackground = Color(
  0xFFE8F5E9,
); // Fond vert très clair pour les cartes

// --- 2. MODÈLE DE DONNÉES (POUR LA SIMULATION) ---
class SponsoredYouth {
  final String name;
  final String formation;
  final bool hasCertificate; // Le nouvel indicateur
  final String avatarAsset; // Asset pour l'avatar (simulé)
  SponsoredYouth(
    this.name,
    this.formation,
    this.hasCertificate,
    this.avatarAsset,
  );
}

// --- 3. WIDGET PRINCIPAL : SponsoredYouthPage ---
class SponsoredYouthPage extends StatefulWidget {
  const SponsoredYouthPage({super.key});

  @override
  State<SponsoredYouthPage> createState() => _SponsoredYouthPageState();
}

class _SponsoredYouthPageState extends State<SponsoredYouthPage> {
  final ParrainagesService _parrainagesService = ParrainagesService();
  final CentresService _centresService = CentresService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  final Map<int, ResponseFormation> _formationsById = {};
  final Map<int, ResponseCentre> _centresById = {};
  // Données de simulation avec le nouvel indicateur
  final List<SponsoredYouth> youths = [
    SponsoredYouth('Ousmane Diallo', 'Mécanique', true, 'male'),
    SponsoredYouth('Kadidja Traoré', 'Couture', true, 'female'),
    SponsoredYouth('Mamadou Kane', 'Développement Web', true, 'male'),
    SponsoredYouth('Aïcha Sidibé', 'Hôtellerie', true, 'female'),
    SponsoredYouth('Issa Touré', 'Électricité Bâtiment', true, 'male'),
    SponsoredYouth('Fatou Camara', 'Design Graphique', true, 'female'),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }
  Future<void> _loadData() async {
    try {
      final items = await _parrainagesService.jeunesParrainesPourMoi();
      await _hydrateFormations();
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }
    Future<void> _hydrateFormations() async {
    try {
      final centresJson = await _centresService.listActifs();
      for (final c in centresJson) {
        final centre = ResponseCentre.fromJson(c);
        _centresById[centre.id] = centre;
        final formations = await _centresService.getFormationsByCentre(centre.id);
        for (final f in formations) {
          final rf = ResponseFormation.fromJson(f);
          _formationsById[rf.id] = rf;
        }
      }
    } catch (_) {}
  }
    int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
  @override
  Widget build(BuildContext context) {
    const double headerHeight = 200.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              title: "Jeunes Parrainées",
              showBackButton: true,
              height: headerHeight,
            ),
          ),
          Positioned.fill(
            top: headerHeight,
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                : _error != null
                    ? Center(child: Text('Erreur: $_error'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 15),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildThanksMessage(),
                              const SizedBox(height: 25),
                              ..._items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: _buildYouthCard(item),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
  // Message de remerciement et icône de cœur
  Widget _buildThanksMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Un grand merci pour',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                Text(
                  'tous les jeunes parrainés',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
          ),
          Icon(Icons.favorite_border, color: primaryGreen, size: 60),
        ],
      ),
    );
  }

  // Carte d'un jeune parrainé avec l'indicateur de certificat
  Widget _buildYouthCard(Map<String, dynamic> item) {
    final jeune = item['jeune'] as Map<String, dynamic>? ?? {};
    final utilisateur = jeune['utilisateur'] as Map<String, dynamic>? ?? {};
    final prenom = (jeune['prenom'] ?? '').toString();
    final nom = (utilisateur['nom'] ?? '').toString();
    final displayName = (prenom.isNotEmpty || nom.isNotEmpty) ? '$prenom $nom'.trim() : 'Jeune';
    final idFormation = _asInt(item['idFormation']);
    final formationTitle = _formationsById[idFormation]?.titre ?? 'Formation #$idFormation';
    final hasCertificate = false; // not available yet

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightGreenBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: primaryBlue.withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              color: primaryBlue.withValues(alpha: 0.8),
              size: 40,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Formation: $formationTitle',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Tooltip(
            message: hasCertificate
                ? 'A obtenu le certificat de fin de formation'
                : 'Formation en cours',
            child: Icon(
              hasCertificate ? Icons.workspace_premium : Icons.pending_actions,
              color: hasCertificate ? primaryGreen : Colors.orange.shade700,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

}
