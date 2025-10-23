import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/parrains/accueilparrain.dart';
import 'package:repartir_frontend/pages/parrains/barnavcustom.dart';
import 'package:repartir_frontend/pages/parrains/dons.dart';
import 'package:repartir_frontend/pages/parrains/formationdetails.dart';
import 'package:repartir_frontend/pages/parrains/profil.dart';

// Couleurs
const Color primaryBlue = Color(0xFF2196F3);
const Color primaryGreen = Color(0xFF4CAF50);

class NavHomePage extends StatefulWidget {
  const NavHomePage({super.key});

  @override
  State<NavHomePage> createState() => _NavHomePageState();
}

class _NavHomePageState extends State<NavHomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [ParrainHomePage(
      onNavigate: _onItemTapped,
    ),DonationsPage(), FormationPage(), ProfilePage()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
