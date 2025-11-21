// edit_profil_mentor_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

// Définition de la couleur (assurez-vous que primaryBlue est accessible)
const Color primaryBlue = Color(0xFF3EB2FF); 

class EditProfilMentorPage extends StatefulWidget {
  const EditProfilMentorPage({super.key});

  @override
  State<EditProfilMentorPage> createState() => _EditProfilMentorPageState();
}

class _EditProfilMentorPageState extends State<EditProfilMentorPage> {
  final ProfileService _profileService = ProfileService();
  final ApiService _api = ApiService();

  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _domaineController = TextEditingController();
  final TextEditingController _aProposController = TextEditingController();
  final TextEditingController _anneeExperienceController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  int? _mentorId;
  String? _currentPhotoUrl;
  
  // Image sélectionnée
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _domaineController.dispose();
    _aProposController.dispose();
    _anneeExperienceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choisir une source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Appareil photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _selectedImage = File(image.path);
          _selectedImageBytes = null;
        });
      }
    } catch (e) {
      debugPrint('Erreur sélection image: $e');
    }
  }

  Future<List<int>> _getImageBytes() async {
    if (_selectedImageBytes != null) {
      return _selectedImageBytes!;
    } else if (_selectedImage != null) {
      return await _selectedImage!.readAsBytes();
    }
    throw Exception('Aucune image sélectionnée');
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final profile = await _profileService.getMe();
      final utilisateur = profile['utilisateur'] ?? {};

      _mentorId = profile['id'];
      _prenomController.text = profile['prenom'] ?? '';
      _nomController.text = utilisateur['nom'] ?? profile['nom'] ?? '';
      _emailController.text = utilisateur['email'] ?? profile['email'] ?? '';
      _telephoneController.text = utilisateur['telephone'] ?? profile['telephone'] ?? '';
      _domaineController.text = profile['profession'] ?? profile['domaine'] ?? '';
      _aProposController.text = profile['a_propos'] ?? profile['aPropos'] ?? '';
      _anneeExperienceController.text = (profile['annee_experience'] ?? profile['anneeExperience'] ?? 0).toString();
      _currentPhotoUrl = utilisateur['urlPhoto'] ?? profile['urlPhoto'];

      setState(() => _loading = false);
    } catch (e) {
      debugPrint('❌ Erreur chargement profil: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      if (_mentorId == null) {
        throw Exception('ID mentor non trouvé');
      }

      // 1. Uploader la photo d'abord si elle a été changée
      if (_selectedImageBytes != null || _selectedImage != null) {
        try {
          final imageBytes = await _getImageBytes();
          final email = _emailController.text;

          debugPrint('📷 Upload de la photo...');
          await _profileService.updatePhoto(imageBytes, email);
          debugPrint('✅ Photo uploadée avec succès');
          
          // Recharger le profil pour obtenir la nouvelle URL de photo
          await _loadProfile();

          // Réinitialiser la sélection d'image
          setState(() {
            _selectedImage = null;
            _selectedImageBytes = null;
          });
        } catch (e) {
          debugPrint('❌ Erreur upload photo: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de l\'upload de la photo: ${e.toString().replaceAll('Exception: ', '')}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _saving = false);
          return; // Arrêter si l'upload de photo échoue
        }
      }

      // 2. Mettre à jour le profil mentor
      final payload = {
        'prenom': _prenomController.text,
        'nom': _nomController.text,
        'telephone': _telephoneController.text,
        'annee_experience': int.tryParse(_anneeExperienceController.text) ?? 0,
        'a_propos': _aProposController.text,
        'profession': _domaineController.text,
      };

      debugPrint('📤 Mise à jour profil mentor: $payload');
      final res = await _api.put('/mentors/$_mentorId', body: jsonEncode(payload));
      _api.decodeJson(res, (d) => d);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retour avec succès
      }
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenu principal avec bordure arrondie
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 30, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Avatar modifiable avec photo
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  _selectedImageBytes != null
                                      ? CircleAvatar(
                                          radius: 60,
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage: MemoryImage(_selectedImageBytes!),
                                        )
                                      : (_selectedImage != null
                                          ? CircleAvatar(
                                              radius: 60,
                                              backgroundColor: Colors.grey[200],
                                              backgroundImage: FileImage(_selectedImage!),
                                            )
                                          : ProfileAvatar(
                                              photoUrl: _currentPhotoUrl,
                                              radius: 60,
                                              isPerson: true,
                                            )),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      backgroundColor: primaryBlue,
                                      radius: 20,
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Champs du formulaire
                          _buildTextFieldWithController(
                            label: 'Prénom',
                            controller: _prenomController,
                          ),
                          _buildTextFieldWithController(
                            label: 'Nom',
                            controller: _nomController,
                            enabled: true, // MODIFIABLE maintenant
                          ),
                          _buildTextFieldWithController(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false, // Non modifiable
                          ),
                          _buildTextFieldWithController(
                            label: 'Téléphone',
                            controller: _telephoneController,
                            keyboardType: TextInputType.phone,
                            enabled: true, // MODIFIABLE maintenant
                          ),
                          _buildTextFieldWithController(
                            label: 'Domaine/Profession',
                            controller: _domaineController,
                          ),
                          _buildTextFieldWithController(
                            label: 'À propos',
                            controller: _aProposController,
                            maxLines: 5,
                            minHeight: 100,
                          ),
                          _buildTextFieldWithController(
                            label: 'Années d\'expérience',
                            controller: _anneeExperienceController,
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 20),

                          // Bouton Enregistrer
                          ElevatedButton(
                            onPressed: _saving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              elevation: 2,
                            ),
                            child: _saving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Enregistrer',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                          ),
                  ],
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              title: "Éditer profil",
              showBackButton: true,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
  
  // Fonction utilitaire pour construire les champs de texte avec controller
  Widget _buildTextFieldWithController({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    double minHeight = 50,
    bool enabled = true,
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
          Container(
            constraints: BoxConstraints(minHeight: minHeight),
            decoration: BoxDecoration(
              color: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction utilitaire pour construire les champs de texte (ancienne version)
  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    double minHeight = 50,
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
          Container(
            constraints: BoxConstraints(minHeight: minHeight),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Widget pour l'avatar modifiable (avec l'icône caméra)
class ProfileEditableAvatar extends StatelessWidget {
  const ProfileEditableAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    // Taille de l'avatar
    const double avatarRadius = 60;

    return SizedBox(
      width: avatarRadius * 2,
      height: avatarRadius * 2,
      child: Stack(
        children: <Widget>[
          // L'avatar principal (le grand cercle)
          Container(
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryBlue.withValues(alpha:0.2), // Fond de l'avatar
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: const Icon(Icons.person, size: 80, color: Colors.blueGrey), // Placeholder
          ),

          // Le petit cercle de modification (Positionné en bas à droite)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // Logique pour ouvrir la galerie/caméra
                debugPrint('Modifier la photo de profil');
              },
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
    );
  }
}