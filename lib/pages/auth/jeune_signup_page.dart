import 'package:flutter/material.dart';
import 'package:repartir_frontend/models/request/jeunerequest.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart';
import 'package:repartir_frontend/services/jeune_service.dart';

class JeuneSignupPage extends StatefulWidget {
  const JeuneSignupPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _JeuneSignupPageState createState() => _JeuneSignupPageState();
}

class _JeuneSignupPageState extends State<JeuneSignupPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _gender = 'homme';
  final Set<int> _selectedDomainIds = {};
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController motDePasseController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController aProposController = TextEditingController();
  final TextEditingController niveauController = TextEditingController();
  final JeuneService jeuneService = JeuneService();
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _domains = [];
  bool _loadingDomains = false;
 
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
      if (_gender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez sélectionner votre genre."),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Créer l'objet JeuneRequest
      debugPrint(_gender);
      final jeuneRequest = JeuneRequest(
        nom: nomController.text,
        prenom: prenomController.text,
        email: emailController.text,
        telephone: telephoneController.text,
        motDePasse: motDePasseController.text,
        genre: _gender!.toUpperCase(),
        age: int.tryParse(ageController.text) ?? 0,
        aPropos: aProposController.text,
        niveau: niveauController.text.isNotEmpty ? niveauController.text : null,
      domaineIds: _selectedDomainIds.isEmpty ? null : _selectedDomainIds.toList(),
      );

      // Appel au backend
      final utilisateur = await jeuneService.registerJeune(jeuneRequest);
if (utilisateur != null && _selectedDomainIds.isNotEmpty) {
       await jeuneService.associateDomaines(utilisateur.id, _selectedDomainIds.toList());
     }
      // Fermer le loader
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

      // Redirection vers AuthenticationPage
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => AccueilPage()),
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
    _loadDomaines();
  }

  Future<void> _loadDomaines() async {
    setState(() => _loadingDomains = true);
    try {
      final domaines = await jeuneService.getDomaines();
      setState(() {
        _domains.clear();
        _domains.addAll(domaines);
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des domaines: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des domaines')),
      );
    } finally {
      setState(() => _loadingDomains = false);
    }
  }

  @override
  void dispose() {
    // On les libère
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    motDePasseController.dispose();
    ageController.dispose();
    aProposController.dispose();
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
          children: [_buildStep1(), _buildStep2()],
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
            _buildHeader("Créez votre profil", "Étape 1 sur 2 (●'◡'●)"),
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
              label: 'Âge',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              controller: ageController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir votre âge';
                }
                final age = int.tryParse(value);
                if (age == null || age < 10 || age > 100) return 'Âge invalide';
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
            
            
            const SizedBox(height: 30),
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
            // Champ Niveau
            _buildInputField(
              label: 'Niveau d’études (optionnel)',
              icon: Icons.school_outlined,
              controller: niveauController,
            ),

            const Text(
              'Genre',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            _buildGenderSelector(),
            const SizedBox(height: 40),
            _buildNavigationButton("Suivant", () {
              if (_formKey.currentState?.validate() == true) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Veuillez remplir correctement tous les champs obligatoires.",
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
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
          _buildHeader("Vos centres d'intérêt", "Étape 2 sur 2 (●'◡'●)"),
           if (_loadingDomains)
            const Center(child: CircularProgressIndicator())
          else if (_domains.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Aucun domaine disponible.', style: TextStyle(color: Colors.black54)),
            )
          else
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
                final id = (domain['id'] as int);
                final libelle = (domain['libelle']?.toString() ?? 'Domaine');
                final isSelected = _selectedDomainIds.contains(id);
                return _buildDomainCard(libelle, isSelected, id);
              },
            ),
         
          const SizedBox(height: 40),
          _buildNavigationButton("S'inscrire", () {         
             if (_formKey.currentState?.validate() != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Veuillez remplir correctement tous les champs obligatoires de l'étape 1.",
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
            submitInscription();
          
          }),
        ],
      ),
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

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildGenderOption("Homme", 'homme'),
          _buildGenderOption("Femme", 'femme'),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String title, String value) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

   Widget _buildDomainCard(String domain, bool isSelected, int domaineId) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDomainIds.remove(domaineId);
          } else {
             _selectedDomainIds.add(domaineId);
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
                color: Colors.blue.withValues(alpha: 0.3),
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
