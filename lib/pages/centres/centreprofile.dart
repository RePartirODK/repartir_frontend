import 'package:flutter/material.dart';

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
      bottomNavigationBar: _buildBottomNavigationBar(_selectedIndex, _onItemTapped),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Header Incurvé
          CurvedHeader(),

          // 2. Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 2.1. Titre et Flèche de Retour + Bouton Éditer
                  _buildHeaderTitle(context),

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

  // --- Widgets de construction des sections ---

  Widget _buildHeaderTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () => Navigator.of(context).pop(), // Action de retour
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Profiles',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // NOUVEAU: Bouton Éditer (Placé à droite, en face de la flèche de retour)
          IconButton(
            icon: const Icon(Icons.edit, color: kPrimaryColor, size: 28),
            onPressed: _handleEditProfile, // Fonction d'édition
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
                child: const Center(child: Icon(Icons.business, size: 60, color: Colors.black54)),
              ),
            ),
          ),
          child: center.imageUrl.startsWith('assets') ? null : const Center(child: Icon(Icons.business, size: 60, color: Colors.black54)),
        ),
        const SizedBox(height: 15),

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
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
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
        _buildSettingItem('Change le mot de passe', Icons.arrow_forward_ios, 
          onTap: () { print('Naviguer vers changer mot de passe'); },
        ),
        
        // 2. Déconnexion
        _buildSettingItem('Déconnexion', Icons.arrow_forward_ios, 
          textColor: Colors.black87, 
          onTap: _handleLogout,
        ),
        
        // 3. Supprimer mon compte
        _buildSettingItem('Supprimer mon compte', Icons.arrow_forward_ios, 
          textColor: kDangerColor, 
          onTap: () { print('Afficher dialogue de confirmation de suppression'); },
        ),
      ],
    );
  }

  Widget _buildSettingItem(String text, IconData icon, {Color textColor = Colors.black87, required VoidCallback onTap}) {
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
              Text(
                text,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              Icon(icon, color: textColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(int currentIndex, Function(int) onTap) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey[600],
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Appliquants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Formations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------
// --- WIDGETS DU HEADER INCURVÉ (réutilisés) ---

class CurvedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double finalHeaderHeight = kHeaderHeight * 0.9; 

    return Container(
      height: finalHeaderHeight, 
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: BottomWaveClipper(),
            child: Container(
              height: finalHeaderHeight,
              color: kPrimaryColor, 
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, 
            left: 20, 
            child: _LogoWidget(),
          ),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
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