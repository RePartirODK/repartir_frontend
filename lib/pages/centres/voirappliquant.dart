import 'package:flutter/material.dart';

// Définition des constantes
const Color kPrimaryColor = Color(0xFF3EB2FF);
const double kHeaderHeight = 200.0;

// **************************************************
// 1. MODÈLES DE DONNÉES
// **************************************************

class Applicant {
  final String name;
  final Color avatarColor;
  final IconData icon; 
  final List<OngoingFormation> ongoingFormations;
  final List<CompletedFormation> completedFormations;

  Applicant({
    required this.name,
    required this.avatarColor,
    required this.icon,
    required this.ongoingFormations,
    required this.completedFormations,
  });
}

class OngoingFormation {
  final String title;
  final int progressPercent;

  OngoingFormation({required this.title, required this.progressPercent});
}

class CompletedFormation {
  final String title;

  CompletedFormation({required this.title});
}

// Données statiques simulées pour Moussa Touré
final Applicant moussaToure = Applicant(
  name: 'Moussa Touré',
  avatarColor: Colors.cyan[600]!,
  icon: Icons.person_4_sharp,
  ongoingFormations: [
    OngoingFormation(title: 'Initiation au design UX/UI', progressPercent: 65),
    OngoingFormation(title: 'Communication professionnelle', progressPercent: 30),
  ],
  completedFormations: [
    CompletedFormation(title: 'Mecanique'),
    CompletedFormation(title: 'Secretariat'),
  ],
);


// **************************************************
// 2. WIDGET STATEFUL DE LA PAGE PROFIL
// **************************************************

class ApplicantProfilePage extends StatefulWidget {
  const ApplicantProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ApplicantProfilePageState createState() => _ApplicantProfilePageState();
}

class _ApplicantProfilePageState extends State<ApplicantProfilePage> {
  // Index 2 pour "Formations" dans la BottomNavigationBar (comme dans vos images)
  int _selectedIndex = 2; 

  // État pour basculer entre les onglets : 'En cours' ou 'Terminés'
  String _currentTab = 'Terminés'; 
  
  // Fonction de mise à jour pour la BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print("Navigating to index: $_selectedIndex");
    });
  }

  // Fonction de mise à jour pour le Toggle Button
  void _setTab(String tabName) {
    setState(() {
      _currentTab = tabName;
    });
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

          // 2. Contenu scrollable (y compris le titre, l'avatar et les listes)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // 2.1. Titre et Flèche de Retour
                  _buildHeader(context, moussaToure),

                  // 2.2. Toggle Button (En cours / Terminés)
                  _buildToggleButtons(),

                  const SizedBox(height: 20),

                  // 2.3. Contenu Dynamique (Liste des formations)
                  _buildFormationList(moussaToure),
                  
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

  Widget _buildHeader(BuildContext context, Applicant applicant) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 20.0, left: 20, right: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () => Navigator.of(context).pop(), 
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Formations', // Le titre de la page est 'Formations'
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Espace pour aligner le titre
              const SizedBox(width: 48), 
            ],
          ),
        ),
        
        // Avatar et Nom
        CircleAvatar(
          radius: 50,
          backgroundColor: applicant.avatarColor.withOpacity(0.8),
          child: Icon(applicant.icon, color: Colors.white, size: 60),
        ),
        const SizedBox(height: 8),
        Text(
          applicant.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: <Widget>[
            _buildToggleItem('En cours'),
            _buildToggleItem('Terminés'),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title) {
    final bool isSelected = _currentTab == title;
    return Expanded(
      child: InkWell(
        onTap: () => _setTab(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormationList(Applicant applicant) {
    if (_currentTab == 'En cours') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Formations en cours",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...applicant.ongoingFormations.map((f) => _buildOngoingFormationCard(f)).toList(),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Formations terminées",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...applicant.completedFormations.map((f) => _buildCompletedFormationCard(f)).toList(),
          ],
        ),
      );
    }
  }

  Widget _buildOngoingFormationCard(OngoingFormation formation) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            // Image de la formation (simulée ici par un placeholder)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.groups, color: kPrimaryColor, size: 30),
              // Normalement, vous utiliseriez Image.asset ou Image.network ici
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formation.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      // Barre de progression
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: formation.progressPercent / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${formation.progressPercent}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedFormationCard(CompletedFormation formation) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            // Image de la formation (simulée ici)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              // Simulation de l'image de la formation
              child: const Icon(Icons.settings, color: Colors.black54, size: 30), 
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  Text(
                    formation.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const Spacer(),
                  // Statut Certificat obtenu
                  const Icon(Icons.workspace_premium, color: Colors.amber, size: 30),
                  const SizedBox(width: 5),
                  const Text(
                    'Certificat obtenu',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
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