import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart'; // Pour les constantes de couleur
import 'package:repartir_frontend/pages/entreprise/accueil_entreprise_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/offre_emploi_service.dart';
import 'package:repartir_frontend/models/offre_emploi.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key});

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  final OffreEmploiService _offreService = OffreEmploiService();
  
  bool _isLoading = true;
  int _totalOffres = 0;
  int _nombreCDI = 0;
  int _nombreCDD = 0;
  int _nombreStage = 0;
  List<Map<String, dynamic>> _statistiquesMensuelles = [];
  List<Map<String, dynamic>> _graphiqueData = [];

  @override
  void initState() {
    super.initState();
    _loadStatistiques();
  }

  Future<void> _loadStatistiques() async {
    setState(() => _isLoading = true);
    try {
      final offres = await _offreService.getMesOffres();
      
      // Calculer les statistiques globales
      _totalOffres = offres.length;
      _nombreCDI = offres.where((o) => o.typeContrat == TypeContrat.CDI).length;
      _nombreCDD = offres.where((o) => o.typeContrat == TypeContrat.CDD).length;
      _nombreStage = offres.where((o) => o.typeContrat == TypeContrat.STAGE).length;
      
      // Calculer les statistiques mensuelles
      _calculerStatistiquesMensuelles(offres);
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Erreur chargement statistiques: $e');
      setState(() => _isLoading = false);
    }
  }

  void _calculerStatistiquesMensuelles(List<OffreEmploi> offres) {
    // Grouper les offres par mois de création (basé sur dateDebut)
    Map<String, int> offresByMonth = {};
    
    for (var offre in offres) {
      final moisAnnee = DateFormat('yyyy-MM').format(offre.dateDebut);
      offresByMonth[moisAnnee] = (offresByMonth[moisAnnee] ?? 0) + 1;
    }
    
    // Trier par date et prendre les 12 derniers mois (ou moins si pas assez de données)
    final sortedKeys = offresByMonth.keys.toList()..sort((a, b) => b.compareTo(a));
    final last12Months = sortedKeys.take(12).toList()..sort();
    
    // Créer les données pour le graphique et la liste
    _graphiqueData = last12Months.map((key) {
      final date = DateTime.parse('$key-01');
      return {
        'mois': DateFormat('MMM').format(date),
        'valeur': offresByMonth[key] ?? 0,
      };
    }).toList();
    
    _statistiquesMensuelles = last12Months.reversed.map((key) {
      final date = DateTime.parse('$key-01');
      return {
        'mois': DateFormat('MMMM yyyy').format(date),
        'offres': offresByMonth[key] ?? 0,
        'date': date,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cartes de résumé
                          _buildSummaryCards(),
                          const SizedBox(height: 20),

                          // Section Évolution des offres publiées
                          if (_graphiqueData.isNotEmpty) ...[
                            _buildEvolutionSection(),
                            const SizedBox(height: 20),
                          ],

                          // Section Détail mensuel
                          if (_statistiquesMensuelles.isNotEmpty) _buildDetailMensuelSection(),
                        ],
                      ),
                    ),
            ),
          ),
          
          // En-tête bleu avec forme ondulée (au-dessus du contenu) avec bouton retour
          CustomHeader(
            showBackButton: true,
            title: 'Statistiques',
          ),
        ],
      ),
    );
  }

  // Cartes de résumé des statistiques
  Widget _buildSummaryCards() {
    return Column(
      children: [
        // Première ligne : Total
        _buildStatCard(
          'Total offres',
          _totalOffres.toString(),
          Icons.work_outline,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        // Deuxième ligne : Types de contrat
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'CDI',
                _nombreCDI.toString(),
                Icons.badge_outlined,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'CDD',
                _nombreCDD.toString(),
                Icons.description_outlined,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Stage',
                _nombreStage.toString(),
                Icons.school_outlined,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Section Évolution des offres publiées
  Widget _buildEvolutionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution des offres publiées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          // Graphique en barres
          _graphiqueData.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Aucune donnée disponible',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              : SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _graphiqueData.map((data) {
                        final maxValue = _graphiqueData
                            .map((e) => e['valeur'] as int)
                            .reduce((a, b) => a > b ? a : b);
                        final height = maxValue > 0 
                            ? (data['valeur'] as int) / maxValue * 150 
                            : 0.0;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Valeur au-dessus de la barre
                              Text(
                                '${data['valeur']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              
                              // Barre
                              Container(
                                width: 35,
                                height: height < 20 ? 20 : height,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.green.shade400,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Label du mois
                              Text(
                                data['mois'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // Section Détail mensuel
  Widget _buildDetailMensuelSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détail mensuel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          
          // Liste des mois
          _statistiquesMensuelles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Aucune donnée mensuelle disponible',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              : Column(
                  children: _statistiquesMensuelles.map((stat) => _buildMoisCard(stat)).toList(),
                ),
        ],
      ),
    );
  }

  // Carte pour chaque mois
  Widget _buildMoisCard(Map<String, dynamic> stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat['mois'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stat['offres']} offres publiées',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${stat['offres']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
