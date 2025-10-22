import 'package:flutter/material.dart';

// Définition des couleurs
const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryGreen = Color(0xFF4CAF50);

/// La barre de navigation inférieure personnalisée pour toute l'application.
class CustomBottomNavBarCentre extends StatelessWidget {
  // L'index de l'onglet actuellement sélectionné (0 pour Accueil, 1 pour Parrainage, etc.)
  final int selectedIndex;
  // Callback pour gérer le changement d'onglet
  final Function(int) onItemTapped;

  const CustomBottomNavBarCentre({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed, // Maintient la couleur et la taille
      elevation: 10,
      currentIndex: selectedIndex,
      selectedItemColor: primaryBlue, // Couleur des icônes/labels sélectionnés
      unselectedItemColor: Colors.grey, // Couleur des icônes/labels non sélectionnés
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: onItemTapped, // Déclenche la fonction passée par la page parente
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home), // Icône remplie pour l'état actif
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.handshake_outlined),
          activeIcon: Icon(Icons.handshake),
          label: 'Appliquants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Formations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}