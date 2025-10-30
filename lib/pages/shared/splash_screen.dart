import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:repartir_frontend/pages/auth/role_selection_page.dart';
import 'package:repartir_frontend/pages/centres/navcentre.dart';
import 'package:repartir_frontend/pages/entreprise/accueil_entreprise_page.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart';
import 'package:repartir_frontend/pages/mentors.dart/navbarmentor.dart';
import 'package:repartir_frontend/pages/parrains/nav.dart';
import 'package:repartir_frontend/pages/onboarding/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // Petite pause pour afficher un splash (optionnel)
    await Future.delayed(const Duration(milliseconds: 500));

    // Vérifier si l'onboarding est terminé
    final onboardingComplete =
        await storage.read(key: 'onboarding_complete') == 'true';

    if (!onboardingComplete) {
      // Nouvel utilisateur → Onboarding
      if (context.mounted) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
        );
      }
      return;
    }

    // Onboarding terminé, vérifier token
    final accessToken = await storage.read(key: 'access_token');
    final userRole = await storage.read(key: 'user_role');

    if (accessToken == null) {
      // Pas de compte logué → page de login
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          // ignore: use_build_context_synchronously
          context,
          '/login',
        );
      }
      return;
    }

    // Utilisateur déjà logué → redirection selon rôle
    Widget targetPage;

    switch (userRole) {
      case 'ROLE_JEUNE':
        targetPage = const AccueilPage();
        break;
      case 'ROLE_MENTOR':
        targetPage = NavHomeMentorPage();
        break;
      case 'ROLE_PARRAIN':
        targetPage = NavHomePage();
        break;
      case 'ROLE_CENTRE':
        targetPage = NavHomeCentrePage();
        break;
      case 'ROLE_ENTREPRISE':
        targetPage = const AccueilEntreprisePage();
        break;
      default:
        targetPage = const AuthenticationPage();
    }

    if (context.mounted) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => targetPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        //mettre logo de l'application ici
        child: CircularProgressIndicator(), // simple loader
      ),
    );
  }
}
