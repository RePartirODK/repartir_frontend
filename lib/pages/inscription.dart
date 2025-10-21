import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/accueilparrain.dart';
import 'package:repartir_frontend/pages/nav.dart';

// --- COULEURS ET CONSTANTES GLOBALES ---
const Color primaryBlue = Color(0xFF3EB2FF); // Couleur principale bleue
const Color inputBackground = Color(0xFFF5F5F5); // Fond légèrement gris pour les champs
const Color secondaryText = Color(0xFF757575); // Couleur pour les textes secondaires

// --- 1. CLASSE CLIPPER (pour la forme 'blob' de l'en-tête) ---
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85); // Début du clip sur la gauche
    
    // Courbe cubique pour la forme irrégulière (le "blob" pour l'en-tête)
    final controlPoint1 = Offset(size.width * 0.25, size.height * 1.15); 
    final controlPoint2 = Offset(size.width * 0.75, size.height * 0.55);
    final endPoint = Offset(size.width, size.height * 0.65);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy, 
      controlPoint2.dx, controlPoint2.dy, 
      endPoint.dx, endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- 2. WIDGET PRINCIPAL : RegistrationPage ---
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // État pour gérer la visibilité du mot de passe
  bool _isPasswordVisible = false;

  // Contrôleurs (non utilisés ici mais bonnes pratiques)
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fonction de simulation d'inscription
  void _handleRegistration() {
  final nom = _nomController.text;
  final email = _emailController.text;

  if (nom.isNotEmpty && email.isNotEmpty) {
    // SnackBar de succès stylé
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating, // Flottant au-dessus du contenu
        margin: const EdgeInsets.all(16), // Espacement avec les bords
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.green.withValues(alpha:0.9),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Inscription de $nom ($email) en cours...',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  
    //navigation vers la page suivante
     Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const NavHomePage()),
      );
    });
  } else {
    // SnackBar d’erreur stylé
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.redAccent.withValues(alpha:0.9),
        duration: const Duration(seconds: 3),
        content: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Veuillez remplir tous les champs.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. En-tête bleu avec le clipper
          _buildHeader(context),
          
          // 2. Contenu principal (scrollable)
          Positioned.fill(
            top: 200, // Démarre le contenu sous le titre
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // --- Nouveau : Grand Titre du Formulaire ---
                    const Text(
                      'Créez votre compte',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Rejoignez la communauté RePartir en quelques étapes.',
                      style: TextStyle(fontSize: 14, color: secondaryText),
                    ),
                    const SizedBox(height: 25),


                    // --- 2.1 Nom & Prénom (sur une seule ligne) ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(_nomController, 'Nom', Icons.person_outline),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildInputField(_prenomController, 'Prénom', Icons.person_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // --- 2.2 Email ---
                    _buildInputField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 15),

                    // --- 2.3 Téléphone ---
                    _buildInputField(_phoneController, 'Téléphone', Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 15),

                    // --- 2.4 Profession ---
                    _buildInputField(_professionController, 'Profession', Icons.work_outline),
                    const SizedBox(height: 15),

                    // --- 2.5 Mot de passe (avec bouton 'voir') ---
                    _buildPasswordInputField(),
                    const SizedBox(height: 40),

                    // --- 2.6 Bouton S'inscrire ---
                    _buildRegistrationButton(),
                    const SizedBox(height: 20), 
                    
                    // --- Nouveau : Lien de connexion ---
                    _buildLoginLink(),
                    const SizedBox(height: 40), // Espace en bas
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // En-tête avec le clipper et le titre
  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: CustomShapeClipper(),
        child: Container(
          height: 200, // Réduit la hauteur pour laisser plus de place au formulaire
          color: primaryBlue,
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Bouton retour
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context), 
                    ),
                    // Titre (plus petit ici car on a un grand titre en bas)
                    Expanded(
                      child: Text(
                        'Inscription',
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Placeholder pour le logo RePartir (alignement)
                    const SizedBox(width: 48), 
                  ],
                ),
                // Logo RePartir 
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('Logo', style: TextStyle(fontSize: 12, color: primaryBlue)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Champ de saisie général avec icône (mise à jour)
  Widget _buildInputField(
    TextEditingController controller, 
    String hintText, 
    IconData icon,
    {TextInputType keyboardType = TextInputType.text}
  ) {
    return Container(
      decoration: BoxDecoration(
        color: inputBackground, // Fond gris clair
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          // Nouvelle icône
          prefixIcon: Icon(icon, color: secondaryText),
          // Supprimer la bordure par défaut
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // Champ de mot de passe avec le bouton de visibilité (mise à jour pour l'icône)
  Widget _buildPasswordInputField() {
    return Container(
      decoration: BoxDecoration(
        color: inputBackground, // Fond gris clair
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible, // Masquer si non visible
        decoration: InputDecoration(
          hintText: 'Mot de passe',
          // Nouvelle icône de clé
          prefixIcon: const Icon(Icons.lock_outline, color: secondaryText),
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          // Bouton pour basculer la visibilité
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: secondaryText,
            ),
            onPressed: () {
              // Basculer l'état
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // Bouton d'inscription (style amélioré)
  Widget _buildRegistrationButton() {
    return SizedBox(
      width: double.infinity,
      height: 55, // Légèrement plus haut
      child: ElevatedButton(
        onPressed: _handleRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Coins arrondis pour correspondre aux inputs
          ),
          elevation: 8, // Ombre plus prononcée
          shadowColor: primaryBlue.withOpacity(0.5), // Ombre bleue
        ),
        child: const Text(
          "S'inscrire",
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Lien de connexion (Nouveau)
  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Logique pour naviguer vers la page de connexion
          print('Naviguer vers la page de Connexion');
        },
        child: RichText(
          text: TextSpan(
            text: 'Déjà un compte ? ',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            children: [
              TextSpan(
                text: 'Se connecter',
                style: TextStyle(
                  fontSize: 16, 
                  color: primaryBlue, 
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


