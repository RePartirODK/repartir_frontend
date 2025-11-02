import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/auth/jeune_signup_page.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:repartir_frontend/pages/auth/entreprise_signup_page.dart';
import 'package:repartir_frontend/pages/auth/parrain_signup_page.dart';
import 'package:repartir_frontend/pages/entreprise/accueil_entreprise_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choisissez un rôle pour continuer votre inscription',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                LayoutBuilder(builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 20) / 2;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _RoleCard(
                          icon: Icons.person_outline,
                          title: 'Jeune',
                          subtitle: 'Je cherche une orientation',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const JeuneSignupPage()),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _RoleCard(
                          icon: Icons.volunteer_activism,
                          title: 'Parrain',
                          subtitle: 'J\'accompagne des jeunes',
                          onTap: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ParrainSignupPage()),
                            );
                          }, 
                        ),
                      ),
                       SizedBox(
                        width: cardWidth,
                        child: _RoleCard(
                          icon: Icons.school_outlined,
                          title: 'Mentor',
                          subtitle: 'Je partage mon experiences',
                          onTap: () {}, // TODO: Implement navigation
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _RoleCard(
                          icon: Icons.business_outlined,
                          title: 'Centre',
                          subtitle: 'Je propose des formations',
                          onTap: () {}, // TODO: Implement navigation
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _RoleCard(
                          icon: Icons.apartment_outlined,
                          title: 'Entreprise',
                          subtitle: 'Je publie des offres d\'emploie',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EntrepriseSignupPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    children: [
                      const TextSpan(text: 'Déjà un compte? '),
                      TextSpan(
                        text: 'Connectez-vous ici',
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AuthenticationPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
