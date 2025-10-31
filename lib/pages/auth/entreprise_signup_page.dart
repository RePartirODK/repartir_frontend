import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart'; // Added import for AuthenticationPage

class EntrepriseSignupPage extends StatefulWidget {
  const EntrepriseSignupPage({super.key});

  @override
  State<EntrepriseSignupPage> createState() => _EntrepriseSignupPageState();
}

class _EntrepriseSignupPageState extends State<EntrepriseSignupPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<String> _selectedDomains = {};
  TextEditingController adresseController = TextEditingController();
    TextEditingController nomController = TextEditingController();
    TextEditingController emailController= TextEditingController();
    TextEditingController motDePasseController= TextEditingController();
    TextEditingController telephoneController= TextEditingController();
    TextEditingController confirmeMotDePasseController= TextEditingController();
    TextEditingController agrementController= TextEditingController();
    final _formKey = GlobalKey<FormState>();
  final List<String> _domains = [
    'Technologie',
    'Marketing',
    'Finance',
    'Vente',
    'Ressources Humaines',
    'Production',
    'Logistique',
    'Service Client',
    'Design',
    'Recherche & Développement',
  ];

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
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [_buildStep1(), _buildStep2()],
      ),
    );
  }

  Widget _buildStep1() {
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Créez votre profil d'entreprise", "Étape 1 sur 2"),
          _buildInputField(
            label: 'Nom de l\'entreprise',
            icon: Icons.business_outlined,
            controller: nomController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le nom de l\'entreprise';
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
              // Here you would typically compare with the original password
              return null;
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
            controller : adresseController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer la localisation';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          _buildNavigationButton("Suivant", () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Vos domaines d'activité", "Étape 2 sur 2"),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
            ),
            itemCount: _domains.length,
            itemBuilder: (context, index) {
              final domain = _domains[index];
              final isSelected = _selectedDomains.contains(domain);
              return _buildDomainCard(domain, isSelected);
            },
          ),
          const SizedBox(height: 40),
          _buildNavigationButton("S'inscrire", () {
            _showSuccessDialog();
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
  }) {
    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      controller: controller,
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

  Widget _buildDomainCard(String domain, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDomains.remove(domain);
          } else {
            _selectedDomains.add(domain);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Text(
            domain,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
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
          shadowColor: Colors.blue.withOpacity(0.4),
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
