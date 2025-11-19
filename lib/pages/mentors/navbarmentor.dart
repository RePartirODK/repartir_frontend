import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/mentors/accueilmentor.dart';
import 'package:repartir_frontend/pages/mentors/custom.dart';
import 'package:repartir_frontend/pages/mentors/formentoring.dart';
import 'package:repartir_frontend/pages/mentors/lesmentores.dart';
import 'package:repartir_frontend/pages/mentors/message.dart';
import 'package:repartir_frontend/pages/mentors/profile_mentor.dart';

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
    _pages = [
      MentorHomePage(),
      MentoresPage(),
      MentoringPage(),
      MentorChatListPage(),
      ProfileMentorPage(),
    ];
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
