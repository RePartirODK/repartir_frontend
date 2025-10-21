import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/parrains/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import pages
import 'package:repartir_frontend/pages/onboarding/onboarding_page.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:repartir_frontend/pages/parrains/accueilparrain.dart';
import 'package:repartir_frontend/pages/parrains/detailsdemande.dart';
import 'package:repartir_frontend/pages/parrains/dons.dart';
import 'package:repartir_frontend/pages/parrains/formationdetails.dart';
import 'package:repartir_frontend/pages/parrains/inscription.dart';
import 'package:repartir_frontend/pages/parrains/jeunesparraines.dart';
import 'package:repartir_frontend/pages/parrains/pagepaiement.dart';
import 'package:repartir_frontend/pages/parrains/profil.dart';
import 'package:repartir_frontend/pages/parrains/voirdetailformation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.onboardingComplete});

  final bool onboardingComplete;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RePartir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => NavHomePage(),
        '/donation': (context) => const DonationsPage(),
        '/details': (context) => const DetailPage(),
        '/formations': (context) => const FormationPage(),
        '/profil': (context) => const ProfilePage(),
        '/formationdetails': (context) => const FormationDetailsPage(),
        '/paiementform': (context) => const PaymentPage(),
        '/parrainés': (context) => SponsoredYouthPage(),
        '/inscriptionparrain': (context) => const RegistrationPage(),
        '/accueil': (context) => const ParrainHomePage(),
      },
    );
  }
}
