import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/password_change_dialog.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/pages/centres/editerprofil.dart';
import 'package:repartir_frontend/provider/centre_provider.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';

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

  // Fonction de déconnexion 
  Future<void> _handleLogout(String email) async {
    try {
      debugPrint("Déconnexion de l'utilisateur...");
    // Logique de déconnexion réelle
    await utilisateurService.logout({'email': email});
    //redirection vers la page de login
    // ignore: use_build_context_synchronously
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      debugPrint("Erreur lors de la deconnexion : $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de se deconnecter le compte $e")),
      );
    }
    
  }

  // Fonction d'édition simulée
  void _handleEditProfile() {
    debugPrint("Naviguer vers le formulaire d'édition de profil...");
    // Logique de navigation vers la page d'édition
    Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const EditProfilCentrePage()),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // empêche la fermeture en cliquant en dehors
      builder: (BuildContext context) {
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
                Navigator.of(context).pop(); // ferme le dialogue
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kDangerColor),
              child: const Text("Supprimer"),
              onPressed: () {
                Navigator.of(context).pop(); // ferme le dialogue
                _deleteAccount(); // ta fonction réelle de suppression
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      debugPrint("Suppression du compte…");
      // Recupérer l'email du centre depuis le stockage sécurisé
      String? email = await storage.getUserEmail();

      // Appeler le service de suppression de compte
      await utilisateurService.suppressionCompte({'email': email!});

      // Puis éventuellement redirige ou déconnecte l'utilisateur
      _handleLogout(email);
    } catch (e) {
      debugPrint("Erreur lors de la suppression : $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de supprimer le compte")),
      );
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
        // Photo de profil / Bannière
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage.assetNetwork(
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: 'assets/center_banner.jpg', // image locale pendant le chargement
          image: centre.urlPhoto != null && centre.urlPhoto!.isNotEmpty
              ? centre.urlPhoto!
              : '', // si pas d'URL, on laissera le placeholder
          imageErrorBuilder: (context, error, stackTrace) {
            // Si erreur réseau ou URL invalide
            return Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.business, size: 60, color: Colors.black54),
              ),
            );
          },
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
          onTap: () async {
            //on recupère l'email du centre depuis le stockage sécurisé
            String? email = await storage.getUserEmail() ;
            debugPrint("Email du centre pour déconnexion : $email");
            _handleLogout(email!);
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
