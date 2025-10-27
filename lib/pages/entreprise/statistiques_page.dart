import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart'; // Pour les constantes de couleur
import 'package:repartir_frontend/pages/entreprise/accueil_entreprise_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key});

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  String _companyName = "TechPartner"; // Placeholder pour le nom de l'entreprise
  int _selectedIndex = 1; // Index pour la barre de navigation

  // Données des statistiques (placeholder)
  final List<Map<String, dynamic>> _statistiquesMensuelles = [
    {'mois': 'Janvier 2025', 'offres': 3},
    {'mois': 'Février 2025', 'offres': 2},
    {'mois': 'Mars 2025', 'offres': 5},
    {'mois': 'Avril 2025', 'offres': 4},
    {'mois': 'Mai 2025', 'offres': 9},
    {'mois': 'Juin 2025', 'offres': 7},
    {'mois': 'Août 2025', 'offres': 4},
    {'mois': 'Octobre 2025', 'offres': 10},
  ];

  // Données pour le graphique
  final List<Map<String, dynamic>> _graphiqueData = [
    {'mois': 'Jan', 'valeur': 3},
    {'mois': 'Fév', 'valeur': 2},
    {'mois': 'Mar', 'valeur': 5},
    {'mois': 'Avr', 'valeur': 4},
    {'mois': 'Mai', 'valeur': 9},
    {'mois': 'Juin', 'valeur': 7},
    {'mois': 'Août', 'valeur': 4},
    {'mois': 'Oct', 'valeur': 10},
  ];

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Évolution des offres publiées
                    _buildEvolutionSection(),
                    const SizedBox(height: 20),

                    // Section Détail mensuel
                    _buildDetailMensuelSection(),
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

  // Contenu de l'en-tête
  Widget _buildHeaderContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Bouton retour
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
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
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _graphiqueData.map((data) {
                final maxValue = _graphiqueData.map((e) => e['valeur'] as int).reduce((a, b) => a > b ? a : b);
                final height = (data['valeur'] as int) / maxValue * 150;
                
                return Column(
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
                      width: 30,
                      height: height,
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
                      ),
                    ),
                  ],
                );
              }).toList(),
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
          ..._statistiquesMensuelles.map((stat) => _buildMoisCard(stat)).toList(),
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
          GestureDetector(
            onTap: () {
              // TODO: Naviguer vers le détail du mois
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Détail de ${stat['mois']}')),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.list_alt,
                color: Colors.blue.shade400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Barre de navigation inférieure
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 5,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey.shade600,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        
        if (index == 0) {
          // Retour à l'accueil entreprise
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AccueilEntreprisePage()),
          );
        } else if (index == 1) {
          // TODO: Naviguer vers la page des offres
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Page des offres')),
          );
        } else if (index == 2) {
          // TODO: Naviguer vers le profil entreprise
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil entreprise')),
          );
        }
      },
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
}
