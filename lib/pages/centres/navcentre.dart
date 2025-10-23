import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/centres/acceuil.dart';
import 'package:repartir_frontend/pages/centres/appliquants.dart';
import 'package:repartir_frontend/pages/centres/centreprofile.dart';
import 'package:repartir_frontend/pages/centres/custombarcentre.dart';
import 'package:repartir_frontend/pages/centres/formation.dart';

// Couleurs
const Color primaryBlue = Color(0xFF2196F3);
const Color primaryGreen = Color(0xFF4CAF50);

class NavHomeCentrePage extends StatefulWidget {
  const NavHomeCentrePage({super.key});

  @override
  State<NavHomeCentrePage> createState() => _NavHomeCentrePageState();
}

class _NavHomeCentrePageState extends State<NavHomeCentrePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [EnhanceHome(),GeneralApplicantsPage(), FormationsPageCentre(), 
    ProfileCentrePage()];
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
      bottomNavigationBar: CustomBottomNavBarCentre(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
