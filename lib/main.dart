import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart';
import 'package:repartir_frontend/pages/onboarding/onboarding_page.dart';
import 'package:repartir_frontend/pages/auth/role_selection_page.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      home: onboardingComplete ? const AuthenticationPage() : const OnboardingPage(),
    );
  }
}
