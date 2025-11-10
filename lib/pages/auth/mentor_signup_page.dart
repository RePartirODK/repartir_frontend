import 'package:flutter/material.dart';
import 'package:repartir_frontend/models/request/mentors_request.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:repartir_frontend/pages/mentors/navbarmentor.dart';
import 'package:repartir_frontend/services/mentor_service.dart';

class MentorSignupPage extends StatefulWidget {
  const MentorSignupPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MentorSignupPageState createState() => _MentorSignupPageState();
}

class _MentorSignupPageState extends State<MentorSignupPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController motDePasseController = TextEditingController();
  final TextEditingController aProposController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final MentorService parrainService = MentorService();
  final TextEditingController anneeExperienceController =
      TextEditingController();
  final MentorService mentorService = MentorService();
  final _formKey = GlobalKey<FormState>();

  Future<void> submitInscription() async {
    //verifier que tous les champs sont valide
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

    // Afficher le loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Créer l'objet JeuneRequest

      final mentorsRequest = MentorsRequest(
        nom: nomController.text,
        prenom: prenomController.text,
        email: emailController.text,
        telephone: telephoneController.text,
        motDePasse: motDePasseController.text,
        profession: professionController.text,
        anneeExperience: int.parse(anneeExperienceController.text),
        aPropos: aProposController.text,
      );

      // Appel au backend
      await mentorService.registerMentor(mentorsRequest);

      // Fermer le loader
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // Redirection vers AuthenticationPage
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => AuthenticationPage()),
        (Route<dynamic> route) => false,
      );

      // Message de succès
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text("Inscription réussie !")));
    } catch (e) {
      // Fermer le loader
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // Afficher l'erreur
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : ${e.toString()}")));
    }
  }

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
    // On les libère
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    motDePasseController.dispose();
    professionController.dispose();
    _pageController.dispose();
    super.dispose();
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
          _buildHeader("Créez votre profil"),
          _buildInputField(
            label: 'Nom',
            icon: Icons.person_outline,
            controller: nomController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir un nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Prénom',
            icon: Icons.person_outline,
            controller: prenomController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir un prenom';
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
                return 'Veuillez saisir un email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Email invalide';
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
                return 'Veuillez saisir un téléphone';
              }
              if (!RegExp(r'^\d+$').hasMatch(value)) {
                return 'Téléphone invalide';
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
                return 'Veuillez saisir un mot de passe';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          _buildInputField(
            label: 'Profession',
            icon: Icons.school_outlined,
            controller: professionController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez remplir le champs';
              }

              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Années d’expérience',
            icon: Icons.timeline_outlined,
            keyboardType: TextInputType.number,
            controller: anneeExperienceController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez indiquer votre nombre d’années d’expérience';
              }
              final intValue = int.tryParse(value);
              if (intValue == null || intValue < 0 || intValue >= 100) {
                return 'Veuillez saisir un nombre valide';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),
          TextFormField(
            controller: aProposController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir un bio';
              }
              return null;
            },
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'À propos de vous',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.info_outline, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),
          _buildNavigationButton("S'inscrire", () {
            submitInscription();
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
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
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      controller: controller,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUnfocus,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
