import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/password_change_dialog.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/pages/centres/editerprofil.dart';
import 'package:repartir_frontend/provider/centre_provider.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';

// Définition des constantes
const Color kPrimaryColor = Color(0xFF3EB2FF);
const double kHeaderHeight = 200.0;
const Color kDangerColor = Color(0xFFE53935); // Rouge pour supprimer le compte

// **************************************************
// 1. WIDGET STATEFUL DE LA PAGE PROFIL
// **************************************************

class ProfileCentrePage extends ConsumerStatefulWidget {
  const ProfileCentrePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileCentrePageState createState() => _ProfileCentrePageState();
}

class _ProfileCentrePageState extends ConsumerState<ProfileCentrePage> {
  final storage = SecureStorageService();
  final utilisateurService = UtilisateurService();

  // Dialog de confirmation de déconnexion
  void _showLogoutDialog() {
    // Stocker le contexte de la page principale
    final mainContext = context;
    
    showDialog(
      context: mainContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône de déconnexion
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 40,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Titre
                const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  'Êtes-vous sûr de vouloir vous déconnecter ?\n\nVous devrez vous reconnecter pour accéder à votre compte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          // Utiliser le contexte du dialog pour le fermer
                          Navigator.of(dialogContext).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Fermer le dialog de confirmation d'abord
                          Navigator.of(dialogContext).pop();
                          
                          // Attendre un court instant pour s'assurer que le dialog est fermé
                          await Future.delayed(const Duration(milliseconds: 100));
                          
                          try {
                            final email = await storage.getUserEmail();
                            if (email != null) {
                              await utilisateurService.logout({'email': email});
                            }
                            await storage.clearTokens();
                            
                            // Naviguer vers la page d'authentification
                            if (mainContext.mounted) {
                              Navigator.pushAndRemoveUntil(
                                mainContext,
                                MaterialPageRoute(builder: (context) => const AuthenticationPage()),
                                (Route<dynamic> route) => false,
                              );
                              ScaffoldMessenger.of(mainContext).showSnackBar(
                                SnackBar(
                                  content: const Text('Déconnexion effectuée'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mainContext.mounted) {
                              ScaffoldMessenger.of(mainContext).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur lors de la déconnexion: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fonction d'édition simulée
  void _handleEditProfile() async {
    debugPrint("Naviguer vers le formulaire d'édition de profil...");
    // Logique de navigation vers la page d'édition
    final result = await Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const EditProfilCentrePage()),
    );
    // Recharger les données après modification (le provider se mettra à jour automatiquement)
    // Le widget se reconstruira automatiquement grâce à ref.watch
  }

  void _showDeleteConfirmationDialog() {
    // Stocker le contexte de la page principale
    final mainContext = context;
    
    showDialog(
      context: mainContext,
      barrierDismissible: false, // empêche la fermeture en cliquant en dehors
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            "Supprimer le compte",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Annuler",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ferme le dialogue
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kDangerColor),
              child: const Text("Supprimer"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ferme le dialogue
                _deleteAccount(); // ta fonction réelle de suppression
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    // Stocker le contexte de la page principale
    final mainContext = context;
    
    try {
      debugPrint("Suppression du compte…");
      // Recupérer l'email du centre depuis le stockage sécurisé
      String? email = await storage.getUserEmail();

      // Appeler le service de suppression de compte
      await utilisateurService.suppressionCompte({'email': email!});

      // Déconnecter l'utilisateur et rediriger vers la page de login
      if (email != null) {
        await utilisateurService.logout({'email': email});
      }
      await storage.clearTokens();
      
      if (mainContext.mounted) {
        Navigator.pushAndRemoveUntil(
          mainContext,
          MaterialPageRoute(builder: (context) => const AuthenticationPage()),
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(mainContext).showSnackBar(
          const SnackBar(
            content: Text('Compte supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Erreur lors de la suppression : $e");
      if (mainContext.mounted) {
        ScaffoldMessenger.of(mainContext).showSnackBar(
          const SnackBar(content: Text("Impossible de supprimer le compte")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final centre = ref.watch(centreNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: centre == null
          ? const Center(child: CircularProgressIndicator())
          : _buildProfilContent(context, centre),
    );
  }

  Widget _buildProfilContent(BuildContext context, ResponseCentre centre) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // 1. Header Incurvé
        CustomHeader(title: "Profile"),

        // 2. Contenu scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 2.2. Photo de profil et Nom du Centre
                _buildCenterInfo(centre),

                const SizedBox(height: 30),

                // 2.3. Section Contact
                _buildContactSection(centre),

                const SizedBox(height: 30),

                // 2.4. Section Paramètres du Compte (avec Déconnexion)
                _buildAccountSettings(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterInfo(ResponseCentre centre) {
    return Column(
      children: [
        // Photo de profil circulaire
        Center(
          child: ProfileAvatar(
            photoUrl: centre.urlPhoto,
            radius: 75,
            isPerson: false,
            cacheKey: DateTime.now().millisecondsSinceEpoch.toString(),
          ),
        ),
        const SizedBox(height: 15),

        //Bouton Edition
        Align(
          alignment: AlignmentGeometry.centerRight,
          child: IconButton(
            icon: const Icon(Icons.edit, color: kPrimaryColor, size: 28),
            onPressed: _handleEditProfile, // Fonction d'édition
          ),
        ),

        // Nom du Centre
        Text(
          centre.nom,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(ResponseCentre centre) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Contact",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),

        // Liste des informations de contact
        _buildContactItem(Icons.location_on, centre.adresse),
        _buildContactItem(Icons.phone, centre.telephone),
        _buildContactItem(Icons.email, centre.email),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Text(value, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Paramètre du compte",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),

        // 1. Changer le mot de passe
        _buildSettingItem(
          'Change le mot de passe',
          Icons.arrow_forward_ios,
          onTap: () {
            debugPrint('Naviguer vers changer mot de passe');
            showPasswordChangeDialog(context);
          },
        ),

        // 2. Déconnexion
        _buildSettingItem(
          'Déconnexion',
          Icons.arrow_forward_ios,
          textColor: Colors.black87,
          onTap: () {
            _showLogoutDialog();
          },
        ),

        // 3. Supprimer mon compte
        _buildSettingItem(
          'Supprimer mon compte',
          Icons.arrow_forward_ios,
          textColor: kDangerColor,
          onTap: () {
            _showDeleteConfirmationDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String text,
    IconData icon, {
    Color textColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text, style: TextStyle(fontSize: 16, color: textColor)),
              Icon(icon, color: textColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
