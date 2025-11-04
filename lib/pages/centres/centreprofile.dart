import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

// Définition des constantes
const Color kPrimaryColor = Color(0xFF3EB2FF);
const double kHeaderHeight = 200.0;
const Color kDangerColor = Color(0xFFE53935); // Rouge pour supprimer le compte

// Modèle de données simple pour le Centre de Formation
class TrainingCenter {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String imageUrl;

  TrainingCenter({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.imageUrl,
  });
}

// Données statiques simulées
final TrainingCenter centerProfile = TrainingCenter(
  name: 'Centre de Formation Professionnelle de Missabougou',
  address: 'Missabougou, rive droite',
  phone: '+22374759999',
  email: 'cfpmissabougou@gmail.com',
  imageUrl: 'assets/center_banner.jpg',
);

// **************************************************
// 1. WIDGET STATEFUL DE LA PAGE PROFIL
// **************************************************

class ProfileCentrePage extends StatefulWidget {
  const ProfileCentrePage({super.key});

  @override
  _ProfileCentrePageState createState() => _ProfileCentrePageState();
}

class _ProfileCentrePageState extends State<ProfileCentrePage> {
  // L'index 3 correspond à "Profil" dans la BottomNavigationBar
  int _selectedIndex = 3;
  final storage = SecureStorageService();

  // Fonction de mise à jour pour la BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print("Navigating to index: $_selectedIndex");
    });
  }

  // Fonction de déconnexion simulée
  void _handleLogout() {
    print("Déconnexion de l'utilisateur...");
    // Logique de déconnexion réelle
  }

  // Fonction d'édition simulée
  void _handleEditProfile() {
    print("Naviguer vers le formulaire d'édition de profil...");
    // Logique de navigation vers la page d'édition
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Header Incurvé
          CustomHeader(title: "Profile"),

          // 2. Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 2.2. Photo de profil et Nom du Centre
                  _buildCenterInfo(centerProfile),

                  const SizedBox(height: 30),

                  // 2.3. Section Contact
                  _buildContactSection(centerProfile),

                  const SizedBox(height: 30),

                  // 2.4. Section Paramètres du Compte (avec Déconnexion)
                  _buildAccountSettings(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterInfo(TrainingCenter center) {
    return Column(
      children: [
        // Photo de profil / Bannière
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(center.imageUrl),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.business, size: 60, color: Colors.black54),
                ),
              ),
            ),
          ),
          child: center.imageUrl.startsWith('assets')
              ? null
              : const Center(
                  child: Icon(Icons.business, size: 60, color: Colors.black54),
                ),
        ),
        const SizedBox(height: 15),
        Align(
          alignment: AlignmentGeometry.centerRight,
          child: IconButton(
            icon: const Icon(Icons.edit, color: kPrimaryColor, size: 28),
            onPressed: _handleEditProfile, // Fonction d'édition
          ),
        ),
        // Nom du Centre
        Text(
          center.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(TrainingCenter center) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Contact",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),

        // Liste des informations de contact
        _buildContactItem(Icons.location_on, center.address),
        _buildContactItem(Icons.phone, center.phone),
        _buildContactItem(Icons.email, center.email),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Text(value, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Paramètre du compte",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),

        // 1. Changer le mot de passe
        _buildSettingItem(
          'Change le mot de passe',
          Icons.arrow_forward_ios,
          onTap: () {
            print('Naviguer vers changer mot de passe');
          },
        ),

        // 2. Déconnexion
        _buildSettingItem(
          'Déconnexion',
          Icons.arrow_forward_ios,
          textColor: Colors.black87,
          onTap: _handleLogout,
        ),

        // 3. Supprimer mon compte
        _buildSettingItem(
          'Supprimer mon compte',
          Icons.arrow_forward_ios,
          textColor: kDangerColor,
          onTap: () {
            print('Afficher dialogue de confirmation de suppression');
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String text,
    IconData icon, {
    Color textColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text, style: TextStyle(fontSize: 16, color: textColor)),
              Icon(icon, color: textColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
