import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/centres/addformation.dart';
import 'package:repartir_frontend/pages/centres/appliquantsformationtermine.dart';
import 'package:repartir_frontend/pages/centres/appliquantsnoncertifie.dart';

// Définition des constantes et modèles de données (réutilisés)
const Color kPrimaryColor = Color(0xFF3EB2FF);
const Color enAttente = Color(0xFFFFC107);
const Color termine = Color(0xFF4CAF50);
const double kHeaderHeight = 200.0;

class Formation {
  final String title;
  final String description;
  final String status;
  Formation({
    required this.title,
    required this.description,
    required this.status,
  });
}

final List<Formation> dummyFormations = [
  Formation(
    title: 'Métallurgie',
    description: 'description de la formation de métallurgie',
    status: "En cours",
  ),
  Formation(
    title: 'Menuiserie',
    description: 'description de la formation de menuiserie',
    status: "En attente",
  ),
  Formation(
    title: 'Maçonnerie',
    description: 'description de la formation de maçonnerie',
    status: "Terminé",
  ),
  Formation(
    title: 'Électricité',
    description: 'description de la formation d\'électricité',
    status: "En cours",
  ),
  Formation(
    title: 'Plomberie',
    description: 'description de la formation de plomberie',
    status: "Terminé",
  ),
];

// **************************************************
// 1. WIDGET STATEFUL POUR GÉRER L'ÉTAT DE LA PAGE
// **************************************************

class FormationsPageCentre extends StatefulWidget {
  const FormationsPageCentre({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FormationsPageCentreState createState() => _FormationsPageCentreState();
}

class _FormationsPageCentreState extends State<FormationsPageCentre> {
  // État actuel de l'index de navigation (Formations est l'index 2)
  int _selectedIndex = 2;

  // Fonction pour mettre à jour l'index sélectionné
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Ici, vous ajouteriez la logique de navigation vers la page correspondante
      print("Navigating to index: $_selectedIndex");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Utilisation de l'état _selectedIndex pour la barre de navigation
      bottomNavigationBar: _buildBottomNavigationBar(
        _selectedIndex,
        _onItemTapped,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header Incurvé
            CurvedHeader(),

            // Section Titre "Formations"
            _buildTitleSection(context),

            // Section "Vos formations" et Bouton Ajouter
            _buildHeaderAndAddButton(),

            // Les Cartes de Formations
            _buildFormationList(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Widgets de construction de la page ---

  Widget _buildTitleSection(BuildContext context) {
    // ... (Reste inchangé)
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 0.0, bottom: 20.0),
        child: Text(
          'Formations',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAndAddButton() {
    // ... (Reste inchangé)
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            "Vos formations",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              // Action: Naviguer vers la page d'ajout de formation

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFormationPage(),
                ),
              );
            },
            mini: true,
            backgroundColor: kPrimaryColor,
            elevation: 4.0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFormationList() {
    // ... (Reste inchangé)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: dummyFormations.map((formation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: _buildFormationCard(formation),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormationCard(Formation formation) {
    // ... (Reste inchangé)
    Color badgeColor;
    Color textColor;
    List<Widget> actionButtons = [];

    switch (formation.status) {
      case "En cours":
        badgeColor = kPrimaryColor;
        textColor = Colors.white;
        actionButtons = [
          _buildActionButton('Voir les appliquants', onPressed: () {
            /**
             * Navigation vers la page d'affichage des appliquants
             */
            Navigator.push(context, MaterialPageRoute(builder: 
            (context)=> const ApplicantsFormationNonTerminePage()
            ));
          }),
          _buildActionButton('Désactiver', onPressed: () {}, isOutline: true),
        ];
        break;
      case "En attente":
        badgeColor = enAttente.withAlpha(10);
        textColor = enAttente;
        actionButtons = [
          _buildActionButton('Voir les appliquants', onPressed: () {
            /**
             * Navigation vers la page d'affichage des appliquants
             */
            Navigator.push(context, MaterialPageRoute(builder: 
            (context)=> const ApplicantsFormationNonTerminePage()
            ));
          }),
          _buildActionButton('Editer', onPressed: () {}, isOutline: true),
        ];
        break;
      case "Terminé":
        badgeColor = termine.withAlpha(10);
        textColor = termine;
        actionButtons = [
          _buildActionButton('Voir les appliquants', onPressed: () {

              //navigation vers la page des appliquants des cours terminés
              Navigator.push(context, 
              MaterialPageRoute(builder: 
              (context) => const ApplicantsFormationTerminePage()
              ));

          }),
        ];
        break;
      default:
        badgeColor = Colors.grey.withAlpha(30);
        textColor = Colors.grey;
        actionButtons = [
          _buildActionButton('Voir les appliquants', onPressed: () {}),
        ];
        break;
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Badge du statut
            _buildStatusBadge(formation.status, badgeColor, textColor),
            const SizedBox(height: 10),

            Row(
              children: [
                if (formation.status == "En cours")
                  const Padding(padding: EdgeInsets.only(right: 8.0)),
                Text(
                  formation.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Description
            Text(
              formation.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 15),

            // Boutons d'action
            Row(children: actionButtons),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color badgeColor, Color textColor) {
    // ... (Reste inchangé)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        status
            .toString()
            .split('.')
            .last
            .replaceFirstMapped(
              RegExp(r'\w'),
              (m) => m.group(0)!.toUpperCase(),
            ),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text, {
    required VoidCallback onPressed,
    bool isOutline = false,
  }) {
    // ... (Reste inchangé)
    final ButtonStyle style = isOutline
        ? OutlinedButton.styleFrom(
            foregroundColor: kPrimaryColor,
            side: const BorderSide(color: kPrimaryColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          )
        : TextButton.styleFrom(
            backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
            foregroundColor: kPrimaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          );

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: isOutline
          ? OutlinedButton(
              onPressed: onPressed,
              style: style,
              child: Text(text, style: const TextStyle(fontSize: 14)),
            )
          : TextButton(
              onPressed: onPressed,
              style: style,
              child: Text(text, style: const TextStyle(fontSize: 14)),
            ),
    );
  }

  Widget _buildBottomNavigationBar(int currentIndex, Function(int) onTap) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey[600],
      currentIndex: currentIndex,
      onTap: onTap, // Utilise la fonction de mise à jour de l'état
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Appliquants'),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Formations',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
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
          // La courbe bleue personnalisée
          ClipPath(
            clipper: BottomWaveClipper(),
            child: Container(height: finalHeaderHeight, color: kPrimaryColor),
          ),
          // Le Logo "RePartir"
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                10, // Utiliser le padding de la status bar
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
