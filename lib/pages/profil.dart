import 'package:flutter/material.dart';

// --- COULEURS ET CONSTANTES GLOBALES ---
const Color primaryBlue = Color(0xFF2196F3); // Couleur principale bleue
const Color primaryRed = Color(0xFFF44336);  // Couleur pour les actions destructives

// --- CLASSE CLIPPER (pour la forme 'blob' de l'en-tête) ---
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    final double startY = size.height * 0.8; 
    path.lineTo(0, startY);
    
    // Courbe cubique pour la forme irrégulière (le "blob")
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


// --- WIDGET PRINCIPAL : ProfilePage ---

class ProfilePage extends StatelessWidget {
  // Simuler les données utilisateur (à remplacer par un modèle/backend)
  final String userName = 'Ousmane Diallo';
  final String userRole = 'Menuisier'; // Peut être Jeune, Parrain, ou un titre pro.
  final String userEmail = 'adiallo7485@gmail.com';
  final String userPhone = '+22376412209';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Utiliser SingleChildScrollView pour assurer la responsivité sur tous les appareils
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. En-tête et Avatar
            _buildProfileHeader(context),
            
            // 2. Sections du profil
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Section 2.1: Information Personnelle ---
                  const Text(
                    'Information Personnelle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
                  ),
                  const SizedBox(height: 15),
                  // Carte Email
                  _buildInfoCard(Icons.email, 'Email', userEmail),
                  const SizedBox(height: 10),
                  // Carte Téléphone
                  _buildInfoCard(Icons.phone, 'Téléphone', userPhone),
                  
                  const SizedBox(height: 40),
                  
                  // --- Section 2.2: Paramètres du Compte ---
                  const Text(
                    'Paramètres du compte',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
                  ),
                  const SizedBox(height: 15),
                  
                  // Option Changer le mot de passe
                  _buildSettingItem(context, 'Changer le mot de passe', () {
                    // Logique pour changer le mot de passe
                    print('Action: Changer mot de passe');
                  }),
                  // Option Supprimer mon compte
                  _buildSettingItem(context, 'Supprimer mon compte', () {
                    // Logique pour supprimer le compte
                    print('Action: Supprimer mon compte');
                  }, isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // En-tête de la page de profil
  Widget _buildProfileHeader(BuildContext context) {
    return Stack(
      children: [
        // Arrière-plan bleu avec le clipper
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(height: 300, color: primaryBlue),
        ),
        
        // Contenu de l'en-tête (Titre, Avatar, Nom)
        Column(
          children: [
            // Barre de titre et Bouton Retour
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 10, right: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context), 
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Avatar de l'utilisateur avec bouton d'édition
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Avatar principal (simulé)
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 80, color: Colors.blueGrey), 
                ),
                // Bouton d'édition d'image
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      print('Action: Changer la photo de profil');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryBlue, width: 2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.camera_alt, color: primaryBlue, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Nom et Rôle
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, 
                color: Colors.black),
            ),
            Text(
              userRole,
              style: TextStyle(fontSize: 16, color: Colors.black
              .withValues(alpha: 0.8)),
            ),
            
            const SizedBox(height: 15),
            
            // Bouton Modifier le Profil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logique pour l'édition de profil
                    print('Edit Profile Pressed');
                  },
                  icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                  label: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Widget pour afficher les informations (Email/Téléphone)
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 24),
          const SizedBox(width: 15),
          Expanded( // Assure que la colonne prend l'espace restant
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                // FittedBox assure que le texte ne déborde pas sur de petits écrans (responsivité)
                FittedBox( 
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour un élément de paramètre du compte
  Widget _buildSettingItem(BuildContext context, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          // Bordure inférieure pour la séparation
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? primaryRed : Colors.black87,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: isDestructive ? primaryRed : Colors.grey),
          ],
        ),
      ),
    );
  }
}

