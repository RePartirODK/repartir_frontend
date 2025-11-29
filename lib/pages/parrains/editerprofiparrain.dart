
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/models/request/parrain_request.dart';
import 'package:repartir_frontend/provider/parrain_provider.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:convert';

const Color primaryBlue = Color(0xFF3EB2FF);

class EditProfilParrainPage extends ConsumerStatefulWidget {
  const EditProfilParrainPage({super.key});

  @override
  ConsumerState<EditProfilParrainPage> createState() =>
      _EditProfilParrainPageState();
}

class _EditProfilParrainPageState extends ConsumerState<EditProfilParrainPage> {
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController professionController;

  final utilisateurService = UtilisateurService();
  final ProfileService _profile = ProfileService();
  bool _saving = false;
  bool _uploadingPhoto = false;
  final storage = SecureStorageService();
  String? _photoUrl;
  String? _photoCacheKey; // Clé de cache pour forcer le rafraîchissement de l'image

  @override
  void initState() {
    super.initState();
    final parrain = ref.read(parrainNotifierProvider);
    nomController = TextEditingController(text: parrain?.nom ?? '');
    prenomController = TextEditingController(text: parrain?.prenom ?? '');
    emailController = TextEditingController(text: parrain?.email ?? '');
    telephoneController = TextEditingController(text: parrain?.telephone ?? '');
    professionController = TextEditingController(text: parrain?.profession ?? '');
    
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    professionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final updated = ParrainRequest(
        nom: nomController.text,
        prenom: prenomController.text,
        email: emailController.text,
        telephone: telephoneController.text,
        motDePasse: '',
        profession: professionController.text,
        urlPhoto: null,
      );
      await ref.read(parrainNotifierProvider.notifier).updateParrain(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      setState(() => _uploadingPhoto = true);
      final picker = ImagePicker();
      
      // Compatible Web et Mobile
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (picked == null) {
        setState(() => _uploadingPhoto = false);
        return;
      }
      
      final email = await storage.getUserEmail();
      if (email == null || email.isEmpty) {
        setState(() => _uploadingPhoto = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email utilisateur introuvable.')),
          );
        }
        return;
      }

      // Lire les bytes de l'image (compatible Web et Mobile)
      final imageBytes = await picked.readAsBytes();
      
      debugPrint('📷 Upload de la photo pour le parrain...');
      debugPrint('📷 Taille fichier: ${imageBytes.length} bytes');
      debugPrint('📷 Email: $email');

      // Upload la photo au backend en utilisant ProfileService (compatible Web)
      final uploadResult = await _profile.updatePhoto(imageBytes, email);
      debugPrint('✅ Photo uploadée avec succès: $uploadResult');

      // Extraire la nouvelle URL de la réponse
      String? newPhotoUrl;
      try {
        final message = uploadResult['message'];
        
        if (message is Map) {
          newPhotoUrl = message['urlPhoto'] as String?;
        } else if (message is String) {
          final decoded = jsonDecode(message);
          if (decoded is Map<String, dynamic> && decoded['urlPhoto'] != null) {
            newPhotoUrl = decoded['urlPhoto'] as String;
          }
        }
        
        if (newPhotoUrl == null && uploadResult['urlPhoto'] != null) {
          newPhotoUrl = uploadResult['urlPhoto'] as String;
        }
        
        debugPrint('🖼️ Nouvelle URL photo extraite: $newPhotoUrl');
      } catch (e) {
        debugPrint('⚠️ Erreur lors de l\'extraction de l\'URL: $e');
      }

      if (newPhotoUrl != null) {
        setState(() {
          _photoUrl = newPhotoUrl;
          // Mettre à jour la clé de cache pour forcer le rafraîchissement de l'image
          _photoCacheKey = '${newPhotoUrl}_${DateTime.now().millisecondsSinceEpoch}';
        });
        
        // Mettre à jour le provider localement
        final parrain = ref.read(parrainNotifierProvider);
        if (parrain != null) {
          final updated = ParrainRequest(
            nom: parrain.nom,
            prenom: parrain.prenom,
            email: parrain.email,
            telephone: parrain.telephone,
            motDePasse: '',
            profession: parrain.profession ?? '',
            urlPhoto: newPhotoUrl,
          );
          ref.read(parrainNotifierProvider.notifier).updateParrainLocally(updated);
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo mise à jour avec succès ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ERREUR lors de l\'upload de la photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la mise à jour: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
    final parrain = ref.watch(parrainNotifierProvider);

    if (parrain == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final photoUrl = (() {
      final top = parrain.urlPhoto;
      final nested = parrain.utilisateur.urlPhoto;
      if (top != null && top.isNotEmpty) return top;
      if (nested != null && nested.isNotEmpty) return nested;
      return null;
    })();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomHeader(title: "Éditer profil", showBackButton: true),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  ProfileAvatar(
                    photoUrl: photoUrl,
                    radius: 60,
                    isPerson: true,
                    cacheKey: _photoCacheKey ?? photoUrl, // Utiliser la clé de cache pour forcer le rafraîchissement
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: primaryBlue, width: 2),
                        ),
                        child: _uploadingPhoto
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue),
                              )
                            : const Icon(Icons.camera_alt, color: primaryBlue, size: 20),
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
                  _buildTextField(label: 'Prénom', controller: prenomController),
                  _buildTextField(label: 'Email', controller: emailController, readOnly: true),
                  _buildTextField(
                    label: 'Téléphone',
                    controller: telephoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(label: 'Profession', controller: professionController),
                  const SizedBox(height: 20),
                   ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      fixedSize: Size(MediaQuery.of(context).size.width * 0.5,
                          MediaQuery.of(context).size.width * 0.129),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}