import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart'; // Pour les constantes de couleur
import 'package:repartir_frontend/pages/entreprise/accueil_entreprise_page.dart';
import 'package:repartir_frontend/pages/entreprise/profil_entreprise_page.dart';

class MesOffresPage extends StatefulWidget {
  const MesOffresPage({super.key});

  @override
  State<MesOffresPage> createState() => _MesOffresPageState();
}

class _MesOffresPageState extends State<MesOffresPage> {
  String _companyName = "TechPartner"; // Placeholder pour le nom de l'entreprise
  int _selectedIndex = 1; // Index pour la barre de navigation

  // Liste des offres publiées (placeholder)
  final List<Map<String, dynamic>> _offres = [
    {
      'titre': 'Développeur Front-End',
      'dateDebut': '01-10-2025',
      'dateFin': '01-10-2025',
      'logo': 'assets/images/logo_repartir.png',
    },
    {
      'titre': 'Développeur Back-End',
      'dateDebut': '15-09-2025',
      'dateFin': '15-10-2025',
      'logo': 'assets/images/logo_repartir.png',
    },
    {
      'titre': 'Designer UI/UX',
      'dateDebut': '20-09-2025',
      'dateFin': '20-11-2025',
      'logo': 'assets/images/logo_repartir.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigation(),
      body: Stack(
        children: [
          // Arrière-plan de la page
          Container(color: Colors.white),

          // En-tête bleu
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: kPrimaryBlue,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeaderContent(),
                ],
              ),
            ),
          ),

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
                  // Section titre et bouton d'ajout
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Mes offres publiées',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Naviguer vers la page d'ajout d'offre
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ajouter une nouvelle offre')),
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: kPrimaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Gérez et suivez vos publications en un clin d\'œil.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Liste des offres
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _offres.length,
                      itemBuilder: (context, index) {
                        final offre = _offres[index];
                        return _buildOffreCard(offre, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
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

        ],
      ),
    );
  }

  // Carte d'offre
  Widget _buildOffreCard(Map<String, dynamic> offre, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo de l'entreprise
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              offre['logo'],
              height: 50,
              width: 50,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),
          
          // Informations de l'offre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offre['titre'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${offre['dateDebut']}/${offre['dateFin']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          Column(
            children: [
              TextButton(
                onPressed: () {
                  // TODO: Naviguer vers les détails de l'offre
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Voir détails de ${offre['titre']}')),
                  );
                },
                child: const Text(
                  'Voir détails',
                  style: TextStyle(
                    color: kPrimaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showDeleteDialog(offre['titre'], index);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog de confirmation de suppression
  void _showDeleteDialog(String titre, int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône de suppression
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 40,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Titre
                const Text(
                  'Supprimer l\'offre',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  'Êtes-vous sûr de vouloir supprimer l\'offre "$titre" ?\n\nCette action est irréversible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _offres.removeAt(index);
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Offre "$titre" supprimée'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
        } else if (index == 2) {
          // Naviguer vers le profil entreprise
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilEntreprisePage()),
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
