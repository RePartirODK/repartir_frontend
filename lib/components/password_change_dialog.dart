import 'package:flutter/material.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';

// --- 1. Le Widget de la boîte de dialogue (le contenu du pop-up) ---

class PasswordChangeDialog extends StatefulWidget {
  const PasswordChangeDialog({super.key});

  @override
  State<PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<PasswordChangeDialog> {
  // Clé pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer les valeurs des champs de texte
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final UtilisateurService _userService = UtilisateurService();
  final SecureStorageService _storage = SecureStorageService();
  bool _submitting = false;

  // NOUVELLES VARIABLES D'ÉTAT pour gérer la visibilité
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Fonction appelée lorsque l'utilisateur appuie sur "Changer"
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text;

    setState(() => _submitting = true);
    try {
      final idStr = await _storage.getUserId();
      final userId = int.tryParse(idStr ?? '0') ?? 0;
      if (userId == 0) {
        throw Exception('Utilisateur non identifié');
      }
      final msg = await _userService.updatePassword(userId, currentPass, newPass);
      // Fermer le pop-up avec succès
      Navigator.of(context).pop(true);
      // Optionnel: feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // Nettoyer les contrôleurs lorsque le widget est supprimé
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Changer mot de passe',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.blue, // Couleur similaire à l'image
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // S'assure que la colonne prend la taille minimale
            children: <Widget>[
              // Champ Mot de passe actuel
              _buildPasswordField(
                controller: _currentPasswordController,
                labelText: 'Mot de passe actuel',
                isVisible: _isCurrentPasswordVisible,
                toggleVisibility: () {
                  setState(() {
                    _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe actuel';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Champ Nouveau mot de passe
              _buildPasswordField(
                controller: _newPasswordController,
                labelText: 'Nouveau mot de passe',
                isVisible: _isNewPasswordVisible,
                toggleVisibility: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nouveau mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit faire au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Champ Confirmer
              _buildPasswordField(
                controller: _confirmPasswordController,
                labelText: 'Confirmer',
                isVisible: _isConfirmPasswordVisible,
                toggleVisibility: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        // Bouton Changer
        SizedBox(
          width: double.infinity, // Pour que le bouton prenne toute la largeur
          child: ElevatedButton(
            onPressed: _submitting ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Couleur de fond du bouton
              foregroundColor: Colors.white, // Couleur du texte
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rayon de bordure
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Changer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
      // Style pour imiter l'image (pas de marge intérieure/extérieure par défaut pour le contenu)
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      // Le padding du titre et des actions est géré par défaut par AlertDialog
    );
  }

  // Widget utilitaire pour les champs de mot de passe (MODIFIÉ)
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    required bool isVisible, // Ajout de l'état de visibilité
    required VoidCallback toggleVisibility, // Ajout de la fonction pour basculer
  }) {
    return TextFormField(
      controller: controller,
      // Utilise l'état `isVisible` pour déterminer si le texte doit être masqué
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        // Bouton d'icône pour basculer la visibilité (AJOUTÉ)
        suffixIcon: IconButton(
          icon: Icon(
            // Change l'icône en fonction de l'état de visibilité
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        ),
        // Style de bordure similaire à l'image
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(color: Colors.green, width: 1.0), // Bordure verte
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(color: Colors.green, width: 2.0), // Bordure verte
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      ),
      validator: validator,
    );
  }
}

// --- 2. Fonction pour afficher le pop-up ---

/// Affiche la boîte de dialogue de changement de mot de passe.
/// Devrait être appelée depuis n'importe quel widget avec un [BuildContext].
Future<void> showPasswordChangeDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return const PasswordChangeDialog();
    },
  );

  // Vous pouvez gérer ici le résultat renvoyé par le pop-up
  if (result == true) {
    // Par exemple, afficher une notification de succès
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mot de passe changé avec succès !')),
    );
  }
}

// --- EXEMPLE D'UTILISATION (Optionnel) ---
/*
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon application')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Appel simple de la fonction pour afficher le pop-up
            showPasswordChangeDialog(context);
          },
          child: const Text('Ouvrir Pop-up MDP'),
        ),
      ),
    );
  }
}
*/