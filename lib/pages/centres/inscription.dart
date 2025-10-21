import 'package:flutter/material.dart';

// Définition de la couleur principale
const Color kPrimaryColor = Color(0xFF3EB2FF);
const double kHeaderHeight = 200.0; 

class InscriptionCentrePage extends StatelessWidget {
  const InscriptionCentrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 1. Le Header Incurvé avec le logo
            CurvedHeader(),

            // 2. Le Titre et le Bouton de Retour
            _buildTitleSection(context),
            
            // 3. Les Champs de Formulaire avec Icônes (NOUVEAU)
            _buildFormFieldsWithIcons(),

            // 4. Le Bouton d'Action
            _buildSignUpButton(context),

            // Espace de sécurité en bas
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Widgets de construction de la page ---

  Widget _buildTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Inscription',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  // NOUVEAU WIDGET : Champs de formulaire avec icônes et ombres
  Widget _buildFormFieldsWithIcons() {
    // Liste des champs avec leurs icônes associées
    final List<Map<String, dynamic>> fields = [
      {'hint': "Nom du centre", 'icon': Icons.business},
      {'hint': "Email du centre", 'icon': Icons.email},
      {'hint': "Ligne téléphonique", 'icon': Icons.phone},
      {'hint': "Numéro d'agrément", 'icon': Icons.verified_user},
      {'hint': "Adresse du centre", 'icon': Icons.location_on},
      {'hint': "Mot de passe", 'icon': Icons.lock},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: fields.map((field) {
          // Utilisation d'un Container pour simuler l'ombre des TextFields
          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2), // Légère ombre pour l'effet 3D
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), 
                  ),
                ],
              ),
              child: TextFormField(
                obscureText: field['hint'].toLowerCase().contains('mot de passe'),
                decoration: InputDecoration(
                  hintText: field['hint'],
                  // Ajout de l'icône
                  prefixIcon: Icon(
                    field['icon'] as IconData,
                    color: Colors.grey[600],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none, // Très important pour garder le style "plat"
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor, 
            minimumSize: const Size(double.infinity, 60), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 0, 
          ),
          onPressed: () {},
          child: const Text(
            "S'inscrire",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// --- WIDGETS DU HEADER (réutilisés) ---

class CurvedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: kHeaderHeight, 
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: BottomWaveClipper(),
            child: Container(
              height: kHeaderHeight,
              color: kPrimaryColor, 
            ),
          ),
          const Positioned(
            top: 50, 
            left: 20, 
            child: _LogoWidget(),
          ),
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