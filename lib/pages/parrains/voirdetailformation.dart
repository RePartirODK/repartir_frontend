import 'package:flutter/material.dart';

// --- COULEURS ET CONSTANTES GLOBALES ---
const Color primaryBlue = Color(0xFF2196F3); // Couleur principale bleue
const Color primaryOrange = Color(0xFFFF9800); // Couleur Orange pour le logo ODC

// --- 1. CLASSE CLIPPER (pour la forme 'blob' de l'en-tête) ---
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85); // Début du clip sur la gauche
    
    // Courbe cubique pour la forme irrégulière (le "blob" pour l'en-tête)
    final controlPoint1 = Offset(size.width * 0.25, size.height * 1.15); 
    final controlPoint2 = Offset(size.width * 0.75, size.height * 0.55);
    final endPoint = Offset(size.width, size.height * 0.65);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy, 
      controlPoint2.dx, controlPoint2.dy, 
      endPoint.dx, endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- 2. WIDGET PRINCIPAL : FormationDetailsPage ---
class FormationDetailsPage extends StatelessWidget {
  const FormationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation de SafeArea pour éviter le chevauchement avec la barre de statut
    return Scaffold(
      body: Stack(
        children: [
          // 1. Arrière-plan bleu avec le clipper
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: CustomShapeClipper(),
              child: Container(
                height: 250, // Hauteur de l'en-tête bleu
                color: primaryBlue,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bouton retour
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context), 
                      ),
                      // Titre
                      Expanded(
                        child: Text(
                          'Formations Details',
                          style: const TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Logo RePartir (simulé en tant qu'espace pour le logo existant)
                      const SizedBox(width: 48), 
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 2. Contenu principal (scrollable)
          Positioned.fill(
            top: 230, // Démarre le contenu sous le titre
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 2.1 Carte Centre de Formation et Titre ---
                    _buildCenterHeaderCard(),
                    const SizedBox(height: 20),
                    
                    // --- 2.2 Titre de la Formation ---
                    const Text(
                      'Développement Web Frontend',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // --- 2.3 Description et Programme ---
                    _buildDescriptionSection(),
                    const SizedBox(height: 20),

                    // --- 2.4 Section Dates ---
                    _buildDateSection(),
                    const SizedBox(height: 25),

                    // --- 2.5 Carte des Détails Pratiques ---
                    _buildPracticalDetailsCard(),
                    const SizedBox(height: 40),

                    // --- 2.6 Bouton d'Action (S'inscrire) ---
                    _buildEnrollButton(context),
                    const SizedBox(height: 40), // Espace en bas
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  // Carte du centre de formation et localisation
  Widget _buildCenterHeaderCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo ODC
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: primaryOrange, width: 2),
          ),
          child: const Center(
            child: Text(
              'Orange\nDigital\nCenter',
              textAlign: TextAlign.center,
              style: TextStyle(color: primaryOrange, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 15),
        // Nom et Lieu
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'ODC_MALI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                children: const [
                  Icon(Icons.location_on, color: Colors.red, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Bamako, Mali',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Section Description et Programme
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Description
        const Text(
          'Cette formation intensive vous permettra de maîtriser les technologies frontend les plus demandées sur le marché. Nos formateurs expérimentés vous guideront à travers des exercices pratiques et des projets concrets pour assurer une montée en compétence rapide et efficace.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 15),

        // Programme
        const Text(
          'Au programme:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        _buildProgramItem('React et son écosystème'),
        _buildProgramItem('TypeScript pour le développement web'),
        _buildProgramItem('Tests unitaires et d\'intégration'),
        _buildProgramItem('Performance et optimisation'),
        _buildProgramItem('Accessibilité web'),
      ],
    );
  }

  // Item du programme avec tiret
  Widget _buildProgramItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 4.0),
      child: Text(
        '- $text',
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  // Section Dates
  Widget _buildDateSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Icon(Icons.calendar_today, color: primaryBlue, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Du 15 septembre 2023 au 15 décembre 2023',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // Carte des détails pratiques (Places, Sommes, Type)
  Widget _buildPracticalDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.1), // Fond bleu très clair
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.people, 'Places disponibles', '12'),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.attach_money, 'Sommes', 'Oui'),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.business, 'Type de formation', 'Présentiel'),
        ],
      ),
    );
  }

  // Ligne de détail dans la carte pratique
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
      ],
    );
  }

  // Bouton d'inscription
  Widget _buildEnrollButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Logique d'inscription
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action: Procéder à l\'inscription')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: const Text(
          "S'inscrire",
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

