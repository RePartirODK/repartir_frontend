import 'package:flutter/material.dart';

// Constantes de couleurs pour un style cohérent
const Color kPrimaryBlue = Color(0xFF007BFF);
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kDarkText = Color(0xFF333333);
const Color kLightText = Color(0xFF757575);

class MesFormationsPage extends StatefulWidget {
  const MesFormationsPage({super.key});

  @override
  State<MesFormationsPage> createState() => _MesFormationsPageState();
}

class _MesFormationsPageState extends State<MesFormationsPage> {
  // Booléen pour gérer l'état du toggle : true = En cours, false = Terminées
  bool _showEnCours = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
      appBar: AppBar(
        backgroundColor: kLightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kDarkText),
          onPressed: () {
            // Le bouton retour renvoie à la page d'accueil
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Mes formations',
          style: TextStyle(
            color: kDarkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // --- Toggle Buttons ---
            _buildToggleButtons(),
            const SizedBox(height: 30),
            // --- Titre de la section ---
            Text(
              _showEnCours ? 'Formations en cours' : 'Formations Terminées',
              style: const TextStyle(
                color: kDarkText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            // --- Contenu conditionnel ---
            Expanded(
              child: _showEnCours ? _buildFormationsEnCours() : _buildFormationsTerminees(),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour les boutons toggle "En cours" et "Terminées"
  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showEnCours = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showEnCours ? kPrimaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'En cours',
                    style: TextStyle(
                      color: _showEnCours ? Colors.white : kDarkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showEnCours = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showEnCours ? kPrimaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'Terminées',
                    style: TextStyle(
                      color: !_showEnCours ? Colors.white : kDarkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la liste des formations "En cours"
  Widget _buildFormationsEnCours() {
    return ListView(
      children: [
        _buildCoursEnCoursCard(
          imagePath: 'assets/images/design_ux_ui.png', // Chemin à remplacer
          title: 'Initiation au design UX/UI',
          progress: 0.65, // 65%
        ),
        const SizedBox(height: 16),
        _buildCoursEnCoursCard(
          imagePath: 'assets/images/communication.png', // Chemin à remplacer
          title: 'Communication professionnelle',
          progress: 0.30, // 30%
        ),
      ],
    );
  }

  /// Construit la liste des formations "Terminées"
  Widget _buildFormationsTerminees() {
    return ListView(
      children: [
        _buildCoursTermineCard(
          imagePath: 'assets/images/design_ux_ui_termine.png', // Chemin à remplacer
          title: 'Initiation au design UX/UI',
        ),
      ],
    );
  }

  /// Widget pour une carte de formation en cours
  Widget _buildCoursEnCoursCard({required String imagePath, required String title, required double progress}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image de la formation (placeholder)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              // Gérer l'erreur si l'image n'est pas trouvée
              errorBuilder: (context, error, stackTrace) {
                return Container(width: 60, height: 60, color: Colors.grey.shade300);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kDarkText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        color: progress > 0.5 ? kPrimaryBlue : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kLightText,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Progression',
                  style: TextStyle(color: kLightText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour une carte de formation terminée
  Widget _buildCoursTermineCard({required String imagePath, required String title}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image de la formation (placeholder)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(width: 60, height: 60, color: Colors.grey.shade300);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kDarkText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.workspace_premium_outlined, color: Colors.orange.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Certificat obtenu',
                      style: TextStyle(
                        color: kLightText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


