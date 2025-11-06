import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:repartir_frontend/pages/centres/navcentre.dart';
import 'package:repartir_frontend/pages/entreprise/accueil_entreprise_page.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart';
import 'package:repartir_frontend/pages/mentors/navbarmentor.dart';
import 'package:repartir_frontend/pages/onboarding/onboarding_page.dart';
import 'package:repartir_frontend/pages/parrains/nav.dart';
import 'package:repartir_frontend/pages/shared/splash_screen.dart';


// Import pages

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final secureStorage = FlutterSecureStorage();
  final onboardingComplete =
      (await secureStorage.read(key: 'onboarding_complete')) == 'true';
  /**
   * Recupération de la valeur du token et du role de l'utilisateur
   */
  final token = await secureStorage.read(key: 'auth_token');
  final role = await secureStorage.read(key: 'user_role');

  late Widget initialPage;

  /**
   * Logique d'entrée de l'application
   */
  if (!onboardingComplete) {
    initialPage = OnboardingPage();
  } else if (token == null) {
    initialPage = AuthenticationPage();
  } else {
    switch (role) {
      case 'JEUNE':
        break;
      case 'MENTOR':
        initialPage = NavHomeMentorPage();
        break;
      case 'PARRAIN':
        initialPage = NavHomePage();
        break;
      case 'CENTRE':
        initialPage = NavHomeCentrePage();
        break;
      case 'ENTREPRISE':
        break;
      default:
        initialPage = AuthenticationPage();
    }
  }
  runApp(const ProviderScope(child: MyApp(initialPage: initialPage)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialPage});
  final Widget initialPage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RePartir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
       home: const SplashScreen(),
      // Tu peux laisser tes routes si tu veux naviguer par nom
      routes: {
        '/login': (context) => AuthenticationPage(),
  '/homecentre': (context) => NavHomeCentrePage(),
  '/homementor': (context) => NavHomeMentorPage(),
  '/homeparrain': (context) => NavHomePage(),
  '/homejeune': (context) => AccueilPage(),
  '/homeentreprise': (context) => const AccueilEntreprisePage(),
      },
    );
  }
}
