import 'package:flutter/material.dart';
import 'package:repartir_frontend/models/request/centre_request.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:repartir_frontend/services/centre_service.dart';

class CentreSignupPage extends StatefulWidget {
  const CentreSignupPage({super.key});

  @override
  State<CentreSignupPage> createState() => _CentreSignupPageState();
}

class _CentreSignupPageState extends State<CentreSignupPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  TextEditingController adresseController = TextEditingController();
  TextEditingController nomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController motDePasseController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController confirmeMotDePasseController = TextEditingController();
  TextEditingController agrementController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final centreService = CentreService();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    adresseController.dispose();
    nomController.dispose();
    emailController.dispose();
    motDePasseController.dispose();
    telephoneController.dispose();
    confirmeMotDePasseController.dispose();
    agrementController.dispose();
    super.dispose();
  }

  Future<void> _submitInscription() async {
    // verifier que le formulaire est valide
    if (_formKey.currentState?.validate() != true) {
      // message d'erreur ou retour
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir correctement tous les champs obligatoires.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // creation d'un map avec les donnees du formulaire
    CentreRequest centreRequest = CentreRequest(
      nom: nomController.text.trim(),
      email: emailController.text.trim(),
      motDePasse: motDePasseController.text.trim(),
      telephone: telephoneController.text.trim(),
      adresse: adresseController.text.trim(),
      agrement: agrementController.text.trim(),
      // domaines: _selectedDomains.toList(),
    );
    debugPrint(centreRequest.toJson().toString());
    //on affiche un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      //appel de l'api
      await centreService.register(centreRequest);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // enlever le loader

      //affichage de la modal de succes
      _showSuccessDialog();
    } catch (e) {
      // Fermer le loader
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // Afficher l'erreur
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur est survenue")));
      debugPrint(
        "Erreur lors de l'inscription de l'entreprise: ${e.toString()}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentPage == 0) {
              Navigator.of(context).pop();
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [_buildStep1()],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Créez votre profil d'entreprise", ''),
          _buildInputField(
            label: 'Nom du centre',
            icon: Icons.business_outlined,
            controller: nomController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le nom du centre';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une adresse email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Veuillez entrer une adresse email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Téléphone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            controller: telephoneController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un numéro de téléphone';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: motDePasseController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Confirmer le mot de passe',
            icon: Icons.lock_reset_outlined,
            obscureText: true,
            controller: confirmeMotDePasseController,

            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer le mot de passe';
              }
              if (value != motDePasseController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              // Here you would typically compare with the original password
              return null;
            },
            onEditingComplete: () {
              setState(() {});

              FocusScope.of(context).unfocus();
            },
          ),

          const SizedBox(height: 20),
          _buildInputField(
            label: 'Numéro d\'agrément',
            icon: Icons.numbers_outlined,
            keyboardType: TextInputType.number,
            controller: agrementController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le numéro d\'agrément';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Localisation',
            icon: Icons.location_on_outlined,
            controller: adresseController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer la localisation';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          _buildNavigationButton("S'inscrire", () {
            _submitInscription();
          }),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Permet de fermer en cliquant à l'extérieur
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: GestureDetector(
            onTap: () {
              // Rediriger vers la page d'authentification après avoir fermé la modal
              Navigator.of(context).pop(); // Ferme la modal
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthenticationPage(),
                ),
                (Route<dynamic> route) => false,
              ); // Redirige vers l'authentification
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Inscription reçue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Nous vous remercions pour votre inscription. Notre équipe va vérifier vos informations dans les plus brefs délais. Nous vous contacterons bientôt pour confirmer votre compte et vous donner accès à nos services.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      margin: const EdgeInsets.only(bottom: 30.0, top: 10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    required TextEditingController controller,
    void Function()? onEditingComplete,
    GlobalKey<FormFieldState<String>>? fieldKey,
  }) {
    return TextFormField(
      key: fieldKey,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      controller: controller,
      onEditingComplete: onEditingComplete,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.blue.withValues(alpha: 0.4),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
