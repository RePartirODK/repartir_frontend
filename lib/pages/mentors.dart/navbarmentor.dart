import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/centres/appliquants.dart';
import 'package:repartir_frontend/pages/centres/centreprofile.dart';
import 'package:repartir_frontend/pages/centres/custombarcentre.dart';
import 'package:repartir_frontend/pages/centres/formation.dart';
import 'package:repartir_frontend/pages/mentors.dart/accueilmentor.dart';
import 'package:repartir_frontend/pages/mentors.dart/custom.dart';

// Couleurs
const Color primaryBlue = Color(0xFF2196F3);
const Color primaryGreen = Color(0xFF4CAF50);

class NavHomeMentorPage extends StatefulWidget {
  const NavHomeMentorPage({super.key});

  @override
  State<NavHomeMentorPage> createState() => _NavHomeMentorPageState();
}

class _NavHomeMentorPageState extends State<NavHomeMentorPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [MentorHomePage(),GeneralApplicantsPage(), FormationsPageCentre(), 
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
      bottomNavigationBar: CustomBottomNavBarMentor(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
