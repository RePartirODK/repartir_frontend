import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/centres/formation.dart';
import 'package:repartir_frontend/pages/parrains/formationdetails.dart';

// Définition de la couleur principale
const Color kPrimaryColor = Color(0xFF3EB2FF);
const double kHeaderHeight = 200.0;

class EnhanceHome extends StatelessWidget {
  const EnhanceHome({super.key});

  VoidCallback? get onPressed => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .grey[50], // Fond très légèrement gris pour faire ressortir les cards

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Le Header Incurvé avec le logo (importé de l'autre page)
            CurvedHeader(),

            // 2. Titre de bienvenue (placé sous le header)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: _buildWelcomeTitle(),
            ),

            // Cartes de statistiques améliorées
            _buildStatCards(context),

            const SizedBox(height: 40),

            // Titre "Actions Rapides"
            _buildQuickActionsTitle(),

            const SizedBox(height: 15),

            // Boutons d'actions rapides
            _buildQuickActionButtons(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Widgets du Header ---

  Widget _buildWelcomeTitle() {
    return const Center(
      child: Text(
        "Bienvenu dans votre\nespace",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          // Carte 1: Formation en cours
          _buildStatCard(
            context,
            title: "Formation en cours",
            value: "5",
            icon: Icons.school_outlined,
            cardColor: const Color(0xFFE0F7FA), // Bleu très doux
            valueColor: Colors.blueGrey[800]!,
          ),
          const SizedBox(height: 20),

          // Carte 2: Nombre de formations
          _buildStatCard(
            context,
            title: "Nombre de formations",
            value: "10",
            icon: Icons.school_outlined,
            cardColor: const Color(0xFFF1F8E9), // Vert très doux
            valueColor: Colors.blueGrey[800]!,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color cardColor,
    required Color valueColor,
  }) {
    // Utilisation de Material pour une élévation et une ombre propres
    return Material(
      color: cardColor,
      elevation: 4.0, // Ajoute une belle ombre
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.w900,
                    color: valueColor,
                  ),
                ),
              ],
            ),
            Icon(icon, size: 85, color: Colors.black.withValues(alpha: 0.15)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        "Actions Rapides",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildActionButton(
              context,
              text: "Demande",
              onPressed: () {
                //navigation vers la page demande
                print("click");
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildActionButton(
              context,
              text: "Formations",

              //navigation vers la page formation
              onPressed: () {
                // Action spécifique pour Demande
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: 
                    (context)=> const FormationsPageCentre()
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String text,
    required Null Function() onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
// ------------------------------------------------------------------
// --- WIDGETS ET CLIPPER DU HEADER INCURVÉ (réutilisés) ---

class CurvedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: kHeaderHeight,
      child: Stack(
        children: <Widget>[
          // La courbe bleue personnalisée
          ClipPath(
            clipper: BottomWaveClipper(),
            child: Container(height: kHeaderHeight, color: kPrimaryColor),
          ),
          // Le Logo "RePartir"
          const Positioned(top: 50, left: 20, child: _LogoWidget()),
          // Optionnel: Ajouter l'heure et les icônes de la barre de statut
          // (cela demande une gestion plus fine de l'espace si l'on veut les centrer parfaitement)
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_work, color: kPrimaryColor, size: 30),
            const Text(
              'RePartir',
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.85);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 3 / 4, size.height * 0.7);
    var secondEndPoint = Offset(size.width, size.height * 0.8);

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
