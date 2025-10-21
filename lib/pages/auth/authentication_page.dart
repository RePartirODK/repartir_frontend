import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/auth/role_selection_page.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart';
import 'package:repartir_frontend/pages/entreprise/accueil_entreprise_page.dart'; // Import de la page d'accueil entreprise

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_repartir.png',
                  height: 150,
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          children: [
                            TextSpan(text: 'Connexion à votre '),
                            TextSpan(text: '\ncompte', style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Entrez vos identifiants pour accéder à votre espace',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      _buildInputField(
                        label: 'Votre adresse email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password logic
                          },
                          child: const Text(
                            'Mot de passe oublié?',
                            style: TextStyle(color: Colors.blue, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // Pour l'instant, nous redirigeons directement vers AccueilEntreprisePage.
                            // Plus tard, cette logique sera conditionnelle au rôle de l'utilisateur.
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const AccueilPage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                          children: [
                            const TextSpan(text: 'Vous n\'avez pas de compte? '),
                            TextSpan(
                              text: 'S\'inscrire',
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                                  );
                                },
                            ),
                          ],
                        ),
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

  Widget _buildInputField({required String label, required IconData icon, TextInputType? keyboardType, bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Votre mot de passe',
        prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey.shade600),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }
}
