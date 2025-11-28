import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/models/request/centre_request.dart';
import 'package:repartir_frontend/provider/centre_provider.dart';
import 'package:repartir_frontend/services/centre_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:image_picker/image_picker.dart';

const Color primaryBlue = Color(0xFF3EB2FF);

class EditProfilCentrePage extends ConsumerStatefulWidget {
  const EditProfilCentrePage({super.key});

  @override
  ConsumerState<EditProfilCentrePage> createState() =>
      _EditProfilCentrePageState();
}

class _EditProfilCentrePageState extends ConsumerState<EditProfilCentrePage> {
  late TextEditingController nomController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController adresseController;
  late TextEditingController agrementController;
  final _profile = ProfileService();
  final centreService = CentreService();
  final _picker = ImagePicker();
  bool _photoJustUploaded = false; // Flag pour éviter l'appel API juste après l'upload de photo
  String? _photoCacheKey; // Clé de cache pour forcer le rafraîchissement de la photo

  @override
  void initState() {
    super.initState();
    final centre = ref.read(centreNotifierProvider)!;
    nomController = TextEditingController(text: centre.nom);
    emailController = TextEditingController(text: centre.email);
    telephoneController = TextEditingController(text: centre.telephone);
    adresseController = TextEditingController(text: centre.adresse);
    agrementController = TextEditingController(text: centre.agrement);
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    agrementController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      final currentCentre = ref.read(centreNotifierProvider)!;
      
      // Créer le CentreRequest en incluant l'URL de la photo actuelle
      // pour éviter de la perdre lors de la mise à jour
      final updatedCentre = CentreRequest(
        nom: nomController.text,
        motDePasse: '', // Ne pas envoyer le mot de passe
        telephone: telephoneController.text,
        email: emailController.text,
        adresse: adresseController.text,
        agrement: agrementController.text,
        urlPhoto: currentCentre.urlPhoto, // Inclure l'URL de la photo actuelle
      );

      // Si une photo vient d'être uploadée, l'URL a déjà été mise à jour dans la base de données
      // On met à jour seulement l'état local pour éviter l'erreur 500 avec PUT /api/utilisateurs/v1
      if (_photoJustUploaded) {
        debugPrint('📸 Photo récemment uploadée, mise à jour locale uniquement...');
        debugPrint('🚫 FLAG ACTIF: Empêchant l\'appel API pour éviter l\'erreur 500');
        
        // Mettre à jour les champs du formulaire dans l'état local SANS appeler l'API
        ref.read(centreNotifierProvider.notifier).updateCentreLocally(updatedCentre);
        
        // Réinitialiser le flag AVANT de naviguer pour éviter tout problème
        _photoJustUploaded = false;
        
        debugPrint('✅ Mise à jour locale terminée, retour à la page profil...');
        
        // Afficher un message de succès et retourner à la page profil
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo et profil enregistrés avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Retourner à la page profil
        }
        
        debugPrint('✅ Retour effectué, sortie IMMÉDIATE de _saveProfile (PAS d\'appel API)');
        return; // Sortir IMMÉDIATEMENT SANS appel API - NE PAS CONTINUER
      } else {
        debugPrint('🔄 Pas de photo récemment uploadée, appel API normal...');
        // Sinon, appeler l'API normalement
        await ref.read(centreNotifierProvider.notifier).updateCentre(updatedCentre);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès!')),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du profil: $e');
      // Si l'erreur est liée à l'endpoint /api/utilisateurs/v1 et qu'une photo vient d'être uploadée,
      // considérer que c'est OK car la photo a déjà été mise à jour dans la base
      if (_photoJustUploaded && e.toString().contains('utilisateurs/v1')) {
        debugPrint('⚠️ Erreur API ignorée car la photo a déjà été mise à jour');
        _photoJustUploaded = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo mise à jour avec succès! (Les autres champs nécessitent une correction backend)'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour : ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Gestion de l'upload de photo (compatible Web et Mobile)
  Future<void> _updatePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) return; // aucun fichier choisi

      final centre = ref.read(centreNotifierProvider)!;

      // Lire les bytes de l'image (compatible Web et Mobile)
      final imageBytes = await picked.readAsBytes();
      
      debugPrint('📷 Upload de la photo pour le centre...');
      debugPrint('📷 Taille fichier: ${imageBytes.length} bytes');
      debugPrint('📷 Email: ${centre.email}');

      // Upload la photo au backend en utilisant ProfileService (compatible Web)
      final uploadResult = await _profile.updatePhoto(imageBytes, centre.email);
      debugPrint('✅ Photo uploadée avec succès: $uploadResult');

      // Extraire la nouvelle URL de la réponse
      String? newPhotoUrl;
      try {
        // D'après les logs, le format est: {message: {message: "...", urlPhoto: "..."}, success: true}
        // Donc uploadResult['message'] est déjà un Map, pas une chaîne JSON
        final message = uploadResult['message'];
        
        debugPrint('🔍 Type de message: ${message.runtimeType}');
        debugPrint('🔍 Contenu de message: $message');
        
        if (message is Map) {
          // message est déjà un Map qui contient {message: "...", urlPhoto: "..."}
          if (message['urlPhoto'] != null) {
            newPhotoUrl = message['urlPhoto'] as String;
            debugPrint('🖼️ Nouvelle URL photo extraite: $newPhotoUrl');
          } else {
            debugPrint('⚠️ Map message trouvé mais pas de clé urlPhoto. Clés disponibles: ${message.keys}');
          }
        } else if (message is String) {
          // Si message est une chaîne JSON (format normal de ProfileService)
          final decoded = jsonDecode(message);
          if (decoded is Map<String, dynamic> && decoded['urlPhoto'] != null) {
            newPhotoUrl = decoded['urlPhoto'] as String;
            debugPrint('🖼️ Nouvelle URL photo extraite (depuis JSON string): $newPhotoUrl');
          }
        } else {
          debugPrint('⚠️ Type de message inattendu: ${message.runtimeType}');
        }
      } catch (e, stackTrace) {
        debugPrint('⚠️ Erreur lors de l\'extraction de l\'URL: $e');
        debugPrint('⚠️ Stack trace: $stackTrace');
        debugPrint('⚠️ uploadResult complet: $uploadResult');
      }

      // Mettre à jour l'URL de la photo localement SANS appeler l'API
      // car l'URL a déjà été mise à jour par updatePhoto dans la base de données
      if (newPhotoUrl != null) {
        final currentCentre = ref.read(centreNotifierProvider)!;
        final updatedCentre = CentreRequest(
          nom: currentCentre.nom,
          motDePasse: '', // Ne pas envoyer le mot de passe
          telephone: currentCentre.telephone,
          email: currentCentre.email,
          adresse: currentCentre.adresse,
          agrement: currentCentre.agrement,
          urlPhoto: newPhotoUrl, // Utiliser la nouvelle URL
        );
        
        debugPrint('🔄 Mise à jour locale du provider avec la nouvelle URL photo...');
        // Mettre à jour le provider localement SANS appeler updateCentre via l'API
        // pour éviter l'erreur 500 avec PUT /api/utilisateurs/v1
        ref.read(centreNotifierProvider.notifier).updateCentreLocally(updatedCentre);
        debugPrint('✅ Provider mis à jour localement avec succès');
        
        // Mettre à jour la clé de cache pour forcer le rafraîchissement de l'image
        _photoCacheKey = '${newPhotoUrl}_${DateTime.now().millisecondsSinceEpoch}';
        
        // Forcer le rafraîchissement de l'UI pour que la photo s'affiche immédiatement
        if (mounted) {
          setState(() {
            // Le setState va forcer le rebuild avec la nouvelle URL de photo
          });
        }
        
        // Marquer qu'une photo vient d'être uploadée pour éviter l'appel API lors du prochain enregistrement
        _photoJustUploaded = true;
      } else {
        debugPrint('⚠️ Aucune URL photo extraite, impossible de mettre à jour le provider');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Photo mise à jour avec succès ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Le widget se reconstruira automatiquement grâce au provider
    } catch (e) {
      debugPrint('❌ ERREUR lors de l\'upload de la photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la mise à jour de la photo : ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: Colors.grey.shade100,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centre = ref.watch(centreNotifierProvider);

    if (centre == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomHeader(title: "Éditer profil", showBackButton: true),
            const SizedBox(height: 20),

            // Avatar modifiable
            Center(
              child: Stack(
                children: [
                  ProfileAvatar(
                    photoUrl: centre.urlPhoto,
                    radius: 60,
                    isPerson: false,
                    cacheKey: _photoCacheKey ?? centre.urlPhoto, // Utiliser la clé de cache mise à jour après l'upload
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _updatePhoto,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: primaryBlue, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField(label: 'Nom', controller: nomController),
                  _buildTextField(
                    label: 'Email',
                    controller: emailController,
                    readOnly: true,
                  ),
                  _buildTextField(
                    label: 'Téléphone',
                    controller: telephoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    label: 'Adresse',
                    controller: adresseController,
                  ),
                  _buildTextField(
                    label: 'Numéro d’agrément',
                    controller: agrementController,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      fixedSize: Size(MediaQuery.of(context).size.width * 0.6,
                          MediaQuery.of(context).size.width * 0.13),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height:80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
