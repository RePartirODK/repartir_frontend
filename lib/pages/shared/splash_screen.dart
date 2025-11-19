import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:repartir_frontend/pages/centres/navcentre.dart';
import 'package:repartir_frontend/pages/entreprise/accueil_entreprise_page.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart';
import 'package:repartir_frontend/pages/mentors/navbarmentor.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo RePartir
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/images/logo_repartir.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Si le logo n'est pas trouvé, afficher un placeholder
                    return const Icon(
                      Icons.school,
                      size: 80,
                      color: Color(0xFF3EB2FF),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Indicateur de chargement
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3EB2FF)),
            ),
            const SizedBox(height: 20),
            // Texte de chargement
            const Text(
              'RePartir',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3EB2FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
